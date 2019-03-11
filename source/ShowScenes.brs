sub ShowServerSelect()
  port = CreateObject("roMessagePort")
  screen = CreateObject("roSGScreen")
  screen.setMessagePort(port)
  scene = screen.CreateScene("ConfigScene")
  screen.show()

  themeScene(scene)
  scene.findNode("prompt").text = "Connect to Serviette"

  config = scene.findNode("configOptions")
  items = [
    {"field": "server", "label": "Host", "type": "string"},
    {"field": "port", "label": "Port", "type": "string"}
  ]
  config.callfunc("setData", items)

  button = scene.findNode("submit")
  button.observeField("buttonSelected", port)

  server_hostname = config.content.getChild(0)
  server_port = config.content.getChild(1)

  while(true)
    msg = wait(0, port)
    if type(msg) = "roSGScreenEvent" and msg.isScreenClosed()
      return
    else if type(msg) = "roSGNodeEvent"
      node = msg.getNode()
      if node = "submit"
        set_setting("server", server_hostname.value)
        set_setting("port", server_port.value)
        return
      end if
    end if
  end while
end sub

sub ShowSignInSelect()
  port = CreateObject("roMessagePort")
  screen = CreateObject("roSGScreen")
  screen.setMessagePort(port)
  scene = screen.CreateScene("ConfigScene")
  screen.show()

  themeScene(scene)
  scene.findNode("prompt").text = "Sign In"

  config = scene.findNode("configOptions")
  items = [
    {"field": "username", "label": "Username", "type": "string"},
    {"field": "password", "label": "Password", "type": "password"}
  ]
  config.callfunc("setData", items)

  button = scene.findNode("submit")
  button.observeField("buttonSelected", port)

  config = scene.findNode("configOptions")

  username = config.content.getChild(0)
  password = config.content.getChild(1)

  while(true)
    msg = wait(0, port)
    if type(msg) = "roSGScreenEvent" and msg.isScreenClosed()
      return
    else if type(msg) = "roSGNodeEvent"
      node = msg.getNode()
      if node = "submit"
        ' Validate credentials
        get_token(username.value, password.value)
        if get_setting("active_user") <> invalid then return
        print "Login attempt failed..."
      end if
    end if
  end while
end sub

sub ShowLibrarySelect()
  port = CreateObject("roMessagePort")
  screen = CreateObject("roSGScreen")
  screen.setMessagePort(port)
  scene = screen.CreateScene("Library")

  screen.show()

  themeScene(scene)

  library = scene.findNode("LibrarySelect")
  libs = LibraryList()
  library.libList = libs

  library.observeField("itemSelected", port)

  while(true)
    msg = wait(0, port)
    if type(msg) = "roSGScreenEvent" and msg.isScreenClosed() then
      exit while
    else if nodeEventQ(msg, "itemSelected")
      target = getMsgRowTarget(msg)
      if target.libraryType = "movies"
        ShowMovieOptions(target.libraryID)
      else if target.libraryType = "tvshows"
        ShowTVShowOptions(target.libraryID)
      else
        print Substitute("Library type {0} is not yet implemented", target.libraryType)
      end if
    end if
  end while
end sub

sub ShowMovieOptions(library_id)
  port = CreateObject("roMessagePort")
  screen = CreateObject("roSGScreen")
  screen.setMessagePort(port)
  scene = screen.CreateScene("Movies")

  screen.show()

  themeScene(scene)

  options = scene.findNode("MovieSelect")
  options_list = ItemList(library_id, {"limit": 30,
    "page": 1,
    "SortBy": "DateCreated,SortName",
    "SortOrder": "Descending" })
  options.movieData = options_list

  options.observeField("itemFocused", port)
  options.observeField("itemSelected", port)

  while true
    msg = wait(0, port)
    if type(msg) = "roSGScreenEvent" and msg.isScreenClosed() then
      return
    else if nodeEventQ(msg, "itemSelected")
      target = getMsgRowTarget(msg)
      ShowMovieDetails(target.movieID)
      'showVideoPlayer(target.movieID)
    else if nodeEventQ(msg, "itemFocused")
      'print "Selected " + msg.getNode()
    end if
  end while
end sub

sub ShowMovieDetails(movie_id)
  port = CreateObject("roMessagePort")
  screen = CreateObject("roSGScreen")
  screen.setMessagePort(port)
  scene = screen.CreateScene("MovieItemDetailScene")

  screen.show()

  themeScene(scene)

  content = createObject("roSGNode", "MovieItemData")
  content.full_data = ItemMetaData(movie_id)
  scene.itemContent = content

  buttons = scene.findNode("buttons")
  buttons.observeField("buttonSelected", port)

  while true
    msg = wait(0, port)
    if type(msg) = "roSGScreenEvent" and msg.isScreenClosed() then
      return
    else if nodeEventQ(msg, "buttonSelected")
      button = msg.getROSGNode()
      if button.buttonSelected = 0
        showVideoPlayer(movie_id)
      end if
    else
      print msg
      print type(msg)
    end if
  end while
end sub

sub ShowTVShowOptions(library_id)
  port = CreateObject("roMessagePort")
  screen = CreateObject("roSGScreen")
  screen.setMessagePort(port)
  scene = screen.CreateScene("TVShows")

  screen.show()

  themeScene(scene)

  options = scene.findNode("TVShowSelect")
  options_list = ItemList(library_id, {"limit": 30,
    "page": 1,
    "SortBy": "DateCreated,SortName",
    "SortOrder": "Descending" })
  options.movieData = options_list

  options.observeField("itemFocused", port)
  options.observeField("itemSelected", port)

  while true
    msg = wait(0, port)
    if type(msg) = "roSGScreenEvent" and msg.isScreenClosed() then
      return
    else if nodeEventQ(msg, "itemSelected")
      target = getMsgRowTarget(msg)
      ShowTVShowDetails(target.movieID)
      'showVideoPlayer(target.movieID)
    else if nodeEventQ(msg, "itemFocused")
      'print "Selected " + msg.getNode()
    end if
  end while
end sub

sub ShowTVShowDetails(show_id)
  port = CreateObject("roMessagePort")
  screen = CreateObject("roSGScreen")
  screen.setMessagePort(port)
  scene = screen.CreateScene("TVShowItemDetailScene")

  screen.show()

  themeScene(scene)

  content = createObject("roSGNode", "TVShowItemData")
  content.full_data = ItemMetaData(show_id)
  scene.itemContent = content

  'buttons = scene.findNode("buttons")
  'buttons.observeField("buttonSelected", port)

  while true
    msg = wait(0, port)
    if type(msg) = "roSGScreenEvent" and msg.isScreenClosed() then
      return
    else if nodeEventQ(msg, "buttonSelected")
      ' What button could we even be watching yet
    else
      print msg
      print type(msg)
    end if
  end while
end sub

sub showVideoPlayer(id)
  port = CreateObject("roMessagePort")
  screen = CreateObject("roSGScreen")
  screen.setMessagePort(port)
  scene = screen.CreateScene("Scene")

  screen.show()

  themeScene(scene)

  VideoPlayer(scene, id)

  while true
    msg = wait(0, port)
    if type(msg) = "roSGScreenEvent" and msg.isScreenClosed() then
      return
    end if
  end while

end sub
