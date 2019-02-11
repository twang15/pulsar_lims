# hi

$ ->

  $(".add-chip-batch-item-btn").on "ajax:success", (event,data) ->
    $rows = $(".chip-batch-item-rows")
    $rows.append(data)

  $(document).on "click", ".chip-batch-create-row-btn", (event) ->
    event.preventDefault()
    event.stopPropagation()
    $form =  $(this).closest("form")
    $.post "/chip_batches/" + $("#record_id").text() + "/create_or_update_chip_batch_item", $form.serialize(), (data) ->
      $form.replaceWith(data)

  $(document).on "change", ".chip-batch-item-form div > *", () ->
    $form =  $(this).closest("form")
    if !($form.has("#chip-batch-item-persisted").length > 0)
      return
    $.post "/chip_batches/" + $("#record_id").text() + "/create_or_update_chip_batch_item", $form.serialize(), (data) ->
      $form.replaceWith(data)

  $(document).on "ajax:success", ".chip-batch-remove-item", (event, data) ->
    $form = $(this).closest("form")
    $form.fadeOut()

  #Refresh the library_prototype list in the form when the refresh fa-icon is clicked:
  $(document).on "click", ".chip_batch_library_prototype i.refresh", (event) ->
    $.get "/libraries/select_options", {prototype: true}, (responseText,status,jqXHR) ->
      $(".chip_batch_library_prototype select").html(responseText)
