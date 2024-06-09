import { App } from 'vue'
import 'maz-ui/styles'
import MazBtn from 'maz-ui/components/MazBtn'
import MazInput from 'maz-ui/components/MazInput'
import MazCheckbox from 'maz-ui/components/MazCheckbox'
import MazTextarea from 'maz-ui/components/MazTextarea'
import MazTransitionExpand from 'maz-ui/components/MazTransitionExpand'
import MazSwitch from 'maz-ui/components/MazSwitch'
import MazPicker from 'maz-ui/components/MazPicker'
import MazBadge from 'maz-ui/components/MazBadge'
import MazSelect from 'maz-ui/components/MazSelect'
import MazDropdown from 'maz-ui/components/MazDropdown'
import MazCarousel from 'maz-ui/components/MazCarousel'
import MazIcon from 'maz-ui/components/MazIcon'
import MazDialog from 'maz-ui/components/MazDialog'
import MazDrawer from 'maz-ui/components/MazDrawer'
import MazDialogPromise from 'maz-ui/components/MazDialogPromise'
import MazCard from 'maz-ui/components/MazCard'
import MazAvatar from 'maz-ui/components/MazAvatar'
import MazCardSpotlight from 'maz-ui/components/MazCardSpotlight'
import MazRadioButtons from 'maz-ui/components/MazRadioButtons'
import MazGallery from 'maz-ui/components/MazGallery'
import MazLazyImg from 'maz-ui/components/MazLazyImg'


import { installToaster, ToasterOptions } from 'maz-ui'


// DEFAULT OPTIONS
const toasterOptions: ToasterOptions = {
  position: 'bottom-right',
  timeout: 10000,
  persistent: false,
}

export default (app: App) => {
  app.component('MazBtn', MazBtn)
  app.component('MazInput', MazInput)
  app.component('MazCheckbox', MazCheckbox)
  app.component('MazTextarea', MazTextarea)
  app.component('MazTransitionExpand', MazTransitionExpand)
  app.component('MazDialogPromise', MazDialogPromise)
  app.component('MazPicker', MazPicker)
  app.component('MazDialog', MazDialog)
  app.component('MazDrawer', MazDrawer)
  app.component('MazSwitch', MazSwitch)
  app.component('MazCard', MazCard)
  app.component('MazAvatar', MazAvatar)
  app.component('MazCardSpotlight', MazCardSpotlight)
  app.component('MazRadioButtons', MazRadioButtons)
  app.component('MazGallery', MazGallery)
  app.component('MazLazyImg', MazLazyImg)
  app.component('MazBadge', MazBadge)
  app.component('MazSelect', MazSelect)
  app.component('MazDropdown', MazDropdown)
  app.component('MazCarousel', MazCarousel)
  // app.component('MazAccordion', MazAccordion)
  
  

  app.component('MazIcon', MazIcon)

  app.provide('mazIconPath', '/icons')
  app.use(installToaster, toasterOptions)
}