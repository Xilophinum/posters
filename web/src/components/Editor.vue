<!-- eslint-disable vue/multi-word-component-names -->
<template>
	<q-card class="q-pa-xs q-ma-xs" id="editor" dark dense bordered type="url" v-show="showing">
        <q-card-section>
            <div class="text-h6 text-center">Image URL</div>
        </q-card-section>
        <q-card-section>
            <q-input v-model="content" label="URL" dark dense />
            <span v-show="error" class="text-negative text-caption text-center">{{ errorMessage }}</span>
        </q-card-section>
        <q-card-actions align="center">
            <q-btn label="Cancel" color="red" icon="fa-solid fa-xmark" @click="cancel" />
            <q-btn label="Save" color="green" icon-right="fa-solid fa-save" @click="saveSettings" :loading="loadImage" />
        </q-card-actions>
    </q-card>
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
            loadImage: false,
            content: "",
            errorMessage: "Invalid image URL provided. Please try again.",
            error: false,
		}
	},
    computed: {

    },
	methods: {
        cancel: function() {
            this.showing = false
            this.store.SendMessage("exit", {})
        },
        saveSettings: async function() {
            this.loadImage = true
            const image = await this.imageValidation(this.content)
            if (!image) {
                this.loadImage = false
                this.error = true
                this.content = ""
                setTimeout(() => {
                    this.error = false
                }, 2500)
                return
            }
            this.showing = false
            this.loadImage = false
            this.store.SendMessage("savePoster", image)
        },
        imageValidation: function(url) {
			return new Promise(resolve => {
                if (!url.startsWith("https")) return resolve(false);
				const image = new Image();
				image.crossOrigin='Anonymous';
				image.onload = () => {
					resolve({
						width: image.naturalWidth,
						height: image.naturalHeight,
						url: url,
					})
				}
                image.onerror = () => {
                    resolve(false)
                }
				image.src = url;
			})
        }
    },
    mounted() {
		this.eventBus.on('openEditor', () => {
			this.showing = true
		})
    },
    unmounted() {
		this.eventBus.off("openEditor");
    },
}
</script>

<style scoped>
#editor {
	position: absolute;
	top: 50%;
	left: 50%;
    transform: translate(-50%, -50%);
    width: 20%;
    height: auto;
}
</style>
