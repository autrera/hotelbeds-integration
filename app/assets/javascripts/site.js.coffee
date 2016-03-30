ready = () ->

  $select = $('.destinations-select').selectize
    onChange: (value) ->
      console.log value
      $('#destination-form').submit()
      return

  return

$(document).ready ready
$(document).on 'page:load', ready
