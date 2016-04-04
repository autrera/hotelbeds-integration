ready = () ->

  $select = $('.destinations-select').selectize
    openOnFocus: false
    onChange: (value) ->
      # $('#destination-form').submit()
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
