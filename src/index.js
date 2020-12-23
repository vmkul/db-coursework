import '../node_modules/@fortawesome/fontawesome-free/css/all.css';
import './styles/layout.sass';
const Vue = require('vue');
const apiAddress = 'http://localhost:4000/';
const app = Vue.createApp({});

const apiReq = async route => (await fetch(apiAddress + route)).json();
const getStatus = async () => (await fetch(apiAddress + 'status')).text();

const postRequest = async (route, body) => {
  return await fetch(apiAddress + route, {
    method: 'POST',
    mode: 'no-cors',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(body),
  });
};

const wait = time =>
  new Promise(resolve => {
    setTimeout(resolve, time);
  });

const filterFactory = (type, field, ...parameters) => {
  let res;
  let castTo;

  parameters.forEach((p, index) => {
    const date = new Date(p);
    if (!isNaN(date) && typeof p === 'string' && p.includes('-')) {
      console.log('date!');
      parameters[index] = date;
      castTo = 'date';
    } else if (!isNaN(parseInt(p))) {
      parameters[index] = parseInt(p);
    }
  });

  const castType = arg => {
    if (castTo === 'date') {
      return new Date(arg);
    } else {
      return arg;
    }
  };

  if (type === 'equal') {
    res = data => castType(data[field]) === parameters[0];
  } else if (type === 'less') {
    res = data => castType(data[field]) < parameters[0];
  } else if (type === 'greater') {
    res = data => castType(data[field]) > parameters[0];
  } else if (type === 'between') {
    res = data => castType(data[field]) >= parameters[0] && castType(data[field]) <= parameters[1];
  }
  console.log(res(new Date('2015')));
  return res;
};

app.component('new-row-form', {
  data() {
    return {
      values: {},
    };
  },

  props: ['fields'],

  template: `<div class="form-container dialog-window">
               <i class="fas fa-times close-form-button" @click="$emit('close')"></i>
               <div class="form-title">
                 <h1>Fill in the form</h1>
               </div>
               <form @submit="submitValues($event)">
                 <div v-for="field in fields" class="form-row">
                   <div class="centered">
                     <label :for="field">{{ field }}</label>
                   </div>
                   <div class="centered">
                     <input type="text" :id="field" v-model="values[field]">
                   </div>
                 </div>
                 <div class="centered submit-button">
                   <input type="submit" value="Add row">
                 </div>
               </form>
            </div>`,

  methods: {
    submitValues(e) {
      e.preventDefault();
      this.$emit('submitValues', this.values);
    },
  },
});

app.component('alert', {
  props: ['type'],

  computed: {
    className() {
      if (this.type === 'success') {
        return 'alert-success';
      } else {
        return 'alert-danger';
      }
    },
  },

  template: `<div :class="['alert', className, 'bottom-alert']" role="alert">
                <slot></slot>
             </div>`,
});

app.component('filter-selector', {
  props: ['isVisible', 'field'],

  data() {
    return {
      filter: 'equal',
      firstParam: '',
      secondParam: '',
    };
  },

  methods: {
    close(e) {
      e.stopPropagation();
      this.$emit('close');
    },

    setFilter() {
      const predicate = filterFactory(
        this.filter,
        this.field,
        this.firstParam,
        this.secondParam
      );
      this.$emit('set', predicate);
    },
  },

  template: `<div class="filter-chooser dialog-window" v-show="isVisible">
                <i class="fas fa-times close-form-button" @click="close"></i>
                <div class="centered"><button @click="$emit('set', '')">Disable</button></div>
                <div class="centered"><input type="text" v-model="firstParam" @input="setFilter"></div>
                <div class="centered"><input type="text" v-model="secondParam" v-show="filter === 'between'" @input="setFilter"></div>
                <div class="centered">
                  <select v-model="filter"  @change="setFilter">
                    <option disabled>Choose a filter</option>
                    <option value="equal">Equal</option>
                    <option value="less">Less than</option>
                    <option value="greater">Greater than</option>
                    <option value="between">Between</option>
                  </select>
                </div>
              </div>`,
});

app.component('query-table', {
  data() {
    return {
      data: '',
      status: {},
      filterSelector: '',
      showForm: false,
      loading: false,
      tables: [],
      filter: '',
      currentTable: '',
      currentPage: 0,
      rowCount: 10,
      stagedChanges: new Map(),
    };
  },

  async mounted() {
    this.loading = true;
    this.tables = await apiReq('get_tables');
    this.currentTable = this.tables[0].TableName;
    this.data = await apiReq(`table?tableName="${this.currentTable}"`);
    this.loading = false;
  },

  methods: {
    async selectTable(table, force) {
      if (this.currentTable === table && !force) return;
      this.currentPage = 0;
      this.currentTable = table;
      this.filterSelector = '';
      this.filter = '';
      this.showForm = false;
      this.stagedChanges = new Map();
      this.loading = true;
      this.data = await apiReq(`table?tableName="${table}"`);
      this.loading = false;
    },

    setPage(page) {
      this.currentPage = page;
    },

    showFilters(column) {
      this.filterSelector = column;
    },

    setFilter(predicate) {
      this.filter = predicate;
    },

    updateField(id, field) {
      if (!this.stagedChanges.get(field)) {
        this.stagedChanges.set(field, new Set());
      }

      this.stagedChanges.get(field).add(id);
    },

    async commitChanges() {
      const payload = [];

      for (const [field, ids] of this.stagedChanges.entries()) {
        Array.from(ids).forEach(id => {
          const index = this.data.indexOf(
            this.data.find(e => {
              return e[Object.keys(e)[0]] === id;
            })
          );

          const record = {
            table: this.currentTable,
            id,
            PK: Object.keys(this.data[0])[0],
            field,
            value: this.data[index][field],
          };

          payload.push(record);
        });
      }

      await postRequest('update', payload);

      this.stagedChanges = new Map();

      const msg = await getStatus();
      if (msg === 'OK') {
        this.status = {
          msg: 'Update success!',
          type: 'success',
        };
        await this.selectTable(this.currentTable, true);
      } else {
        this.status = {
          msg,
          type: 'danger',
        };
      }
    },

    async deleteRow(table, field, id) {
      await postRequest('delete', { table, field, id });

      const msg = await getStatus();

      if (msg === 'OK') {
        this.status = {
          msg: 'Delete success!',
          type: 'success',
        };
        await this.selectTable(this.currentTable, true);
      } else {
        this.status = {
          msg,
          type: 'danger',
        };
      }
    },

    async createRow(fields) {
      await postRequest('insert', { fields, table: this.currentTable });

      const msg = await getStatus();

      if (msg === 'OK') {
        this.status = {
          msg: 'Create row success!',
          type: 'success',
        };
        await this.selectTable(this.currentTable, true);
      } else {
        this.status = {
          msg,
          type: 'danger',
        };
      }
      this.showForm = false;
    },
  },

  computed: {
    filtered() {
      let res = [];
      if (typeof this.filter === 'string') {
        res = this.data;
      } else {
        res = this.data.filter(this.filter);
      }

      return res;
    },

    pages() {
      const pages = [];
      const pageCount = Math.ceil(this.filtered.length / this.rowCount);

      for (let i = 0; i < pageCount; i++) {
        pages.push([]);
      }

      for (let i = 0; i < this.filtered.length; i++) {
        const page = Math.floor(i / this.rowCount);
        pages[page].push(this.filtered[i]);
      }

      this.currentPage = 0;
      return pages;
    },
  },

  template: `      
      <new-row-form v-if="showForm" :fields="Object.keys(data[0]).slice(1)" @submitValues="createRow" @close="showForm = false"></new-row-form>
      <div>
        <button
            v-for="table in tables"
            :key="table"
            :class="['tab-button', { active: table.TableName === currentTable }]"
            @click="selectTable(table.TableName)"
        >
        {{ table.TableName }}
        </button>
      </div>
      <div class="centered">
        <div class="row-count">
          <label for="rowCount" class="row-label">Row count:</label>
          <input type="number" min="1" v-model="rowCount" class="row-count-input">
        </div>
        <div class="row-count">
          <button @click="showForm = true"><i class="fas fa-plus"></i> New row</button>
        </div>
      </div>
      <div class="centered">
        <img v-show="loading" class="loader" src="images/loader.gif" alt="loader">
      </div>
      <div class="centered">
        <table class="query-table" v-show="!loading">
          <tr>
            <th v-for="(field, value) in data[0]" @click="showFilters(value)">
              {{ value }}
              <filter-selector @close="showFilters('')" @set="setFilter" :isVisible="filterSelector === value" :field="value">
              </filter-selector>
            </th>
          </tr>
          <tr v-for="row in pages[currentPage]">
            <td v-for="(value, field, index) in row">
              <div v-if="index !== 0">
                <input type="text" v-model="this.data[this.data.indexOf(row)][field]"
                     @input="updateField(row[Object.keys(row)[0]], field)">
              </div>
              <div v-else>
                <i @click="deleteRow(this.currentTable, Object.keys(row)[0], row[Object.keys(row)[0]])" class="delete-button fas fa-trash"></i>
                {{ value }}
              </div>
            </td>
          </tr>
        </table>
      </div>
      <div class="centered">
        <button v-for="page in pages.length" @click="setPage(page - 1)">{{ page }}</button>
      </div>
      <div class="centered"><button v-show="stagedChanges.size > 0" @click="commitChanges">Commit to database</button></div>
      <alert v-if="status.msg" :type="status.type">{{ status.msg }}</alert>
  `,
});

app.mount('#main');
