<template>
    <div id="app">
		<Editor />
		<Poster />
    </div>
</template>

<script>
import { useStore } from './stores/store'
import Poster from './components/Poster.vue'
import Editor from './components/Editor.vue';

export default {
	name: 'App',
	components: {
		Poster,
		Editor
	},
	setup () {
        const store = useStore();
        return { store }
	},
	methods: {
		eventHandler: function(event) {
			this.eventBus.emit(event.data.action, event.data)
		},
	},
	mounted() {
		window.addEventListener("message", this.eventHandler);
		this.store.SendMessageAsync("loaded", {}).then(data => {
			this.store.resourcename = data.resName;
		});
	},
	unmounted() {
		window.removeEventListener("message", this.eventHandler);
	}
}
</script>

<style>
body, html {
	width: 100%;
	height: 100%;
}

::-webkit-scrollbar {
	width: 0px;
	background: transparent;
}
</style>