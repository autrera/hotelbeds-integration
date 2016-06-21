ready = () ->

  $('.loader').addClass 'hidden'

  showLoader = () ->
    $('.loader').removeClass 'hidden'
    return

  $('a.with-loader').on 'click', (event) ->
    showLoader()
    return

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

  conektaSuccessResponseHandler = (token) ->
    $form = $("#new-reservation-form")
    $form.append($("<input type='hidden' name='conektaTokenId'>").val(token.id))
    $form.get(0).submit()
    showLoader()
    return

  conektaErrorResponseHandler = (response) ->
    $form = $("#new-reservation-form")
    $form.find(".card-errors").text(response.message)
    $form.find("button").prop("disabled", false)
    return

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
      alert("Selecciona un destino, por favor.")
      return
    return

  if $('select[name=number_of_rooms]').length > 0

    $('select[name=number_of_rooms]').trigger 'change'
    $('select.children_in_room').trigger 'change'
    return

  if $('#reservation-submit').length > 0

    $('#reservation-submit').on 'click', (event) ->
      event.preventDefault()
      $('.form-control.error').removeClass 'error'

      if $('input[name=holder_name]').val() == ""
        $('input[name=holder_name]').addClass 'error'
        return

      if $('input[name=holder_surname]').val() == ""
        $('input[name=holder_surname]').addClass 'error'
        return

      if $('input[name=holder_email]').val() == ""
        $('input[name=holder_email]').addClass 'error'
        return

      if $('input[name=holder_phone]').val() == ""
        $('input[name=holder_phone]').addClass 'error'
        return

      number_of_rooms = $('#number_of_rooms').val()
      for i in [1..number_of_rooms]
        number_of_adults = $('#room_' + i + '_adults').val()
        number_of_children = $('#room_' + i + '_children').val()

        for j in [1..number_of_adults]
          if $('#room_' + i + '_adult_' + j + '_name').val() == ""
            $('#room_' + i + '_adult_' + j + '_name').addClass 'error'
            return

          if $('#room_' + i + '_adult_' + j + '_surname').val() == ""
            $('#room_' + i + '_adult_' + j + '_surname').addClass 'error'
            return

        for k in [1..number_of_children]
          if $('#room_' + i + '_child_' + k + '_name').val() == ""
            $('#room_' + i + '_child_' + k + '_name').addClass 'error'
            return

          if $('#room_' + i + '_child_' + k + '_surname').val() == ""
            $('#room_' + i + '_child_' + k + '_surname').addClass 'error'
            return

      if $('input[name=card_holder_name]').val() == ""
        $('input[name=card_holder_name]').addClass 'error'
        return

      if $('input[name=card_number]').val() == ""
        $('input[name=card_number]').addClass 'error'
        return

      if $('input[name=card_cvc]').val() == ""
        $('input[name=card_cvc]').addClass 'error'
        return

      # Conekta.setPublishableKey('key_ERsAnyHxGz7r4R71vmPfQxw');

      $form = $('#new-reservation-form')

      # Previene hacer submit más de una vez
      $form.find("button").prop("disabled", true)
      # Conekta.token.create($form, conektaSuccessResponseHandler, conektaErrorResponseHandler)

      $('#new-reservation-form').submit()

      return

    return

  return

$(document).ready ready
$(document).on 'page:load', ready
