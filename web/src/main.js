import { createApp } from 'vue'

import { createPinia } from 'pinia'

import { Quasar } from 'quasar'
import quasarIconSet from 'quasar/icon-set/fontawesome-v6'
import '@quasar/extras/roboto-font/roboto-font.css'
import '@quasar/extras/fontawesome-v6/fontawesome-v6.css'
import 'quasar/dist/quasar.css'
import '@fortawesome/fontawesome-free/css/fontawesome.min.css'
import '@fortawesome/fontawesome-free/css/all.min.css'

import mitt from "mitt";
const eventBus = mitt();

import App from './App.vue'

const app = createApp(App)
app.config.globalProperties.eventBus = eventBus;
app.use(Quasar, {
    plugins: {},
    iconSet: quasarIconSet,
    config: {
        brand: {
            primary: '#673AB7',
            secondary: '#1e1e1ef9',
            accent: '#EBEBEB17',
        }
    }
})
app.use(createPinia())
app.mount('#app')