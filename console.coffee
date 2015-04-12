
inherits = require('inherits');
EventEmitter = require('events').EventEmitter;

Modal = require 'voxel-modal'
ConsoleWidget = require 'console-widget'

module.exports = (game, opts) -> new Console(game, opts)
module.exports.pluginInfo =
  loadAfter: ['voxel-keys']

class Console extends Modal
  constructor: (@game, @opts) ->
    return if not @game.isClient

    @opts.includeTextBindings ?= {
      'console': undefined,
      console2: '/',
      console3: '.'}

    # options for ConsoleWidget
    widgetOpts = @opts  # pass through voxel-console opts (no need to copy)

    # nothing closes the widget, hide/show is handled by voxel-modal
    widgetOpts.closeKeys = []
    @widget = ConsoleWidget(widgetOpts)
    #@widget.on 'input', (text) =>  # TODO: handle events, pass up?
    #  @widget.log "You said: #{text}"

    @keys = game.plugins.get('voxel-keys') ? throw new Error('voxel-console requires voxel-keys plugin')
    @bindKeys()

    super game, {element: @widget.containerNode}
  inherits(Console, EventEmitter)

  bindKeys: () ->
    #@game.buttons.bindings.console ?= 'T' # TODO: bind these keys ourselves?
    #@game.buttons.bindings.console2 ?= '/'  # maybe with game-shell, game.shell.bind()
    #@game.buttons.bindings.console3 ?= '.'

    ['console', 'console2', 'console3'].forEach (binding) =>
      @keys.down.on binding, () =>
        initialText = @opts.includeTextBindings[binding]
        @open(initialText)

  open: (initialText=undefined) ->
    super()
    @emit('open')
    @on 'open', =>
      console.log 'opened'

    @widget.open(initialText)

  close: () ->
    super()
    console.log("closed")
    @emit('close')
    @on 'close', =>
      console.log 'closed'
    #@widget.close()  # modal hides everything

  log: (text) ->
    @widget.log(text)

  logNode: (node) ->
    @widget.logNode(node)
