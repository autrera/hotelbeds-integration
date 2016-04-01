ready = () ->

  $select = $('.destinations-select').selectize
    onChange: (value) ->
      console.log value
      $('#destination-form').submit()
      return

  $('.owl-carousel').owlCarousel
    stagePadding: 50
    loop: true
    margin: 10
    items: 1
    lazyLoad: true

  return

$(document).ready ready
$(document).on 'page:load', ready
