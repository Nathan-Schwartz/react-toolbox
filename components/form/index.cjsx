###
@todo
###

require "./style"
Autocomplete  = require "../autocomplete"
Button        = require "../button"
Input         = require "../input"

module.exports = React.createClass

  # -- States & Properties
  propTypes:
    attributes        : React.PropTypes.array
    storage           : React.PropTypes.string
    className         : React.PropTypes.string
    # -- Events
    onSubmit          : React.PropTypes.func
    onError           : React.PropTypes.func
    onValid           : React.PropTypes.func
    onChange          : React.PropTypes.func

  getDefaultProps: ->
    attributes        : []

  getInitialState: ->
    attributes        : @storage @props

  # -- Lifecycle
  componentWillReceiveProps: (next_props) ->
    @setValue (item for item in @storage next_props) if next_props.attributes

  # -- Events
  onSubmit: (event) ->
    event.preventDefault()
    @props.onSubmit? event, @

  onChange: (event) ->
    is_valid = true
    value = @getValue()
    for attr in @state.attributes when attr.required and value[attr.ref]?.trim() is ""
      is_valid = false
      @refs[attr.ref].setError? "Required field"
      break

    @props.onChange? event, @
    @storage @props, value if @props.storage
    if is_valid
      @refs.submit?.getDOMNode().removeAttribute "disabled"
      @props.onValid? event, @
    else
      @refs.submit?.getDOMNode().setAttribute "disabled", true
      @props.onError? event, @

  # -- Render
  render: ->
    <form data-component-form className={@props.className}
          onSubmit={@onSubmit} onChange={@onChange}>
      {
        for attribute, index in @state.attributes
          if attribute.type is "submit"
            <Button {...attribute} type="square" ref="submit" onClick={@onSubmit}/>
          else if attribute.type is "autocomplete"
            <Autocomplete {...attribute} onChange={@onChange}/>
          else
            <Input {...attribute} />
      }
      { @props.children }
    </form>

  # -- Extends
  storage: (props, value) ->
    key = "react-toolbox-form-#{props.storage}"
    if value
      store = {}
      store[attr.ref] = value[attr.ref] for attr in props.attributes when attr.storage
      window.localStorage.setItem key, JSON.stringify store
    else if props.storage
      store = JSON.parse window.localStorage.getItem key or {}
      input.value = store?[input.ref] or input.value for input in props.attributes
    props.attributes

  getValue: ->
    value = {}
    value[ref] = el.getValue() for ref, el of @refs when el.getValue?
    value

  setValue: (data = {}) ->
    @refs[field.ref].setValue? field.value for field in data
