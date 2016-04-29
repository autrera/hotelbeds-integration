ready = () ->

  showLoader = () ->
    $('.loader').removeClass 'hidden'
    return

  $('a.with-loader').on 'click', (event) ->
    showLoader()
    return

  $('form').on 'submit', () ->
    showLoader()

  @select = $('.destinations-select').selectize
    openOnFocus: false
    onChange: (value) ->
      # $('#destination-form').submit()
      return

  datepicker_options =
    autoclose: true
    startDate: $('#start-date').val()
    endDate: $('#end-date').val()
    # language: $('#locale').val()
    format: 'mm/dd/yyyy'
    # format: 'dd/mm/yyyy'
    # format: 'MM d yyyy'

  $('input[name=check_in]').datepicker(datepicker_options).on 'changeDate', (e) ->
    return

  $('.owl-carousel').owlCarousel
    stagePadding: 10
    loop: true
    items: 1
    lazyLoad: true

  $('select[name=number_of_rooms]').on 'change', (event) =>
    $('.room_row').addClass 'hide'
    value = parseInt $(event.target).val(), 10
    for i in [0..value]
      $('.room_' + i + '_row').removeClass 'hide'
    return

  $('select.children_in_room').on 'change', (event) =>
    value = parseInt $(event.target).val(), 10
    name  = $(event.target).attr 'name'
    class_parts = name.split('_')
    room_number = parseInt class_parts[1], 10
    $('div[class^=room_' + room_number + '_child_]').addClass 'hide'
    if value > 0
      for i in [1..value]
        $('.room_' + room_number + '_child_' + i + '_age').removeClass 'hide'
    return

  $('#destination-form button').on 'click', (event) =>
    event.preventDefault()
    if @select.val() != ""
      $('#destination-form').submit()
    else
      alert("Enter a destination, please.")
      return
    return

  if $('select[name=number_of_rooms]').length > 0

    $('select[name=number_of_rooms]').trigger 'change'
    $('select.children_in_room').trigger 'change'
    return

  return

$(document).ready ready
$(document).on 'page:load', ready
