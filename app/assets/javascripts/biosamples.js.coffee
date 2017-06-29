# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->

  load_biosampel_term_name_selection = -> 
    if $("#biosample_biosample_type_id").val()
      $.get "/biosamples/select_biosample_term_name", $("#biosample_biosample_type_id").serialize(), (responseText,status,jqXHR) ->
        $(".biosample_term_name").html(responseText)

  #use event delegation (see jQuery in Action 3rd ed., p. 154 on "event delegation").
  $(document).on "change", "#biosample_biosample_type_id", (event) -> 
    # $(document).change "#biosample_biosample_type_id", (event) -> 
    # Note that using the CoffeeScript syntax (commented-out line above) for event delegation doesn't work, as any change events (i.e. selecting a document) cause the event below to fire.
    event.stopPropagation()
    load_biosampel_term_name_selection()
