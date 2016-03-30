ready = () ->

  eventHandler = (name) =>
    console.log(name, arguments)
    return

  $('.destinations-select').selectize
    onChange: eventHandler 'onChange'

  return

$(document).ready ready
$(document).on 'page:load', ready
