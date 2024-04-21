<!-- eslint-disable vue/multi-word-component-names -->
<template>
	<q-img :src="imageSrc" :width="width + 'px'" :height="height + 'px'" id="chalkboard" v-show="showing" />
</template>

<script>
import { useStore } from '../stores/store'

export default {
	components: {
		
	},
	setup () {
        const store = useStore();
		return {
            store
		}
	},
	data() {
		return {
			showing: false,
			imageSrc: "",
			width: 1920,
			height: 1080,
		}
	},
    computed: {

    },
	methods: {

    },
    mounted() {
		this.eventBus.on('setDUIVariables', (data) => {
			this.showing = true
			this.imageSrc = data.imageSrc
			this.width = data.width
			this.height = data.height
		})
    },
    unmounted() {
		this.eventBus.off("setDUIVariables");
    },
}
</script>

<style scoped>
#chalkboard {
	position: absolute;
	top: 0;
	left: 0;
}
</style>
