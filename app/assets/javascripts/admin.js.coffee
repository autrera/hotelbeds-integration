ready = () ->

  datepicker_options =
    endDate: $('#max-date').val()
    format: 'mm/dd/yyyy'

  $('.input-daterange').datepicker(datepicker_options).on 'changeDate', (e)->
    return

  # $('#end_date').datepicker(datepicker_options).on 'changeDate', (e)->
  #   return

  # end_date_pieces = $('#max_date').val().split('-')
  # max_date = new Date end_date_pieces[0],   end_date_pieces[1] - 1,   end_date_pieces[2],   0, 0, 0, 0

  # checkin = $('#start_date').datepicker({
  #   format: 'mm/dd/yyyy'
  #   onRender: (date) ->
  #     if date.valueOf() > max_date.valueOf()
  #       return 'disabled'
  #     return ''
  # }).on('changeDate', (ev) ->
  #   if ev.date.valueOf() > checkout.date.valueOf()
  #     newDate = new Date ev.date
  #     newDate.setDate newDate.getDate()
  #     checkout.setValue(newDate)
  #   checkin.hide()
  #   $('#end_date').focus()
  #   return
  # ).data('datepicker')
  # checkout = $('#end_date').datepicker(
  #   format: 'mm/dd/yyyy'
  #   onRender: (date) ->
  #     if date.valueOf() > max_date.valueOf()
  #       return 'disabled'
  #     return ''
  # ).on('changeDate', (ev) ->
  #   if ev.date.valueOf() < checkin.date.valueOf()
  #     newDate = new Date ev.date
  #     newDate.setDate newDate.getDate()
  #     checkin.setValue(newDate)
  #     $('#start_date').focus()
  #   checkout.hide()
  #   return
  # ).data('datepicker')

  $.material.init()

$(document).ready ready
$(document).on 'page:load', ready
