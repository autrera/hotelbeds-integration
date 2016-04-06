ready = () ->

  $select = $('.destinations-select').selectize
    openOnFocus: false
    onChange: (value) ->
      # $('#destination-form').submit()
      return

  $('.owl-carousel').owlCarousel
    stagePadding: 10
    loop: true
    items: 1
    lazyLoad: true

  $('select[name=number_of_rooms]').on 'change', (event) =>
    $('.room_row').addClass 'hide'
    value = $(event.target).val()
    for i in [0..value]
      $('.room_' + i + '_row').removeClass 'hide'
    return

  return

$(document).ready ready
$(document).on 'page:load', ready
