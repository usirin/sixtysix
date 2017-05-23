pageRouter = require 'page'

module.exports = class Router

  ###*
   * Return page.js instance
  ###
  @getPageRouter = -> pageRouter
  getPageRouter: -> pageRouter

  constructor: (options = {}) ->

    ###*
     * Routes mapped as 'path' => 'callback'
    ###
    @routes     = {}

    ###*
     * Exit routes mapped as 'path' => 'callback'
    ###
    @exitRoutes = {}

    ###*
     * Base path.
    ###
    @basePath = options.basePath or ''

    ###*
     * Default route.
    ###
    @defaultRoute = options.defaultRoute or '/'


  ###*
   * Returns the default route.
   *
   * @param {String} default route
  ###
  getDefaultRoute: -> @defaultRoute


  ###*
   * It registers a route with given pattern
   * with the given callback(s).
   *
   * @todo add multiple callback registration for single route.
   * @todo add typedef definition for callback parameter.
   *
   * @param {String|RegExp} pattern
   * @param {...Function} callbacks
  ###
  addRoute: (pattern, callbacks...) ->

    @routes[pattern] = callbacks
    pageRouter pattern, callbacks...

    return this


  ###*
   * It registers multiple routes.
   *
   * @param {Object<String|RegExp, Function>} routes - keys as pattern, values as callbacks.
  ###
  addRoutes: (routes) ->

    @addRoute pattern, callback  for pattern, callback of routes

    return this


  ###*
   * It registers an exit route to be called when leaving a route.
   *
   * @param {String|RegExp} pattern
   * @param {...Function} callbacks
  ###
  exitRoute: (pattern, callbacks...) ->

    @exitRoutes[pattern] = callbacks
    pageRouter.exit pattern, callbacks...

    return this


  ###*
   * Cleans the state of pageRouter.
   *
   * @api private - helper
  ###
  @cleanPageRouter = cleanPageRouter = ->

    pageRouter.stop()
    pageRouter.callbacks = []
    pageRouter.exits = []


  ###*
   * Registers all the routes to pageRouter(`page.js`)
   * And starts listening via page.js.
   * All heavy lifting is done by page.js
  ###
  listen: ->

    # Set base path
    pageRouter.base @basePath

    # Start listening router.
    pageRouter.start()

    return this


  ###*
   * Executes the given route callbacks if being listened.
   *
   * @param {String} route - route to be executed.
  ###
  handleRoute: (route) ->

    pageRouter route

    return this


  ###*
   * It goes back in history.
   *
   * @param {String=} route - Routes to this route if there is no history.
  ###
  back: (route) ->

    route or= @getDefaultRoute()

    pageRouter.back route

    return this


  ###*
   * It goes forward in history.
  ###
  forward: ->

    history.forward()

    return this


  ###*
   * Returns current path.
   *
   * @return {String} current path
  ###
  getCurrentPath: -> pageRouter.current


  ###*
   * Replaces current path with default path.
   * It accepts to be compatible with `KDRouter` api.
   *
   * @deprecated @param {String} route
  ###
  clear: (route) ->

    # KDRouter compatibility
    if route?
      console.warn [
        'Usage of Router::clear with a route argument is deprecated.'
        'Use Router::replace instead.'
      ].join ' '

      @replaceRoute route

    pageRouter.replace @getDefaultRoute()

    return this


  ###*
   * Replaces the route with modifying current history entry.
   *
   * @param {String} route
  ###
  replaceRoute: (route) ->

    pageRouter.replace route

    return this


  redirect: (route) ->

    pageRouter.redirect route

    return this

