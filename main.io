WebRequest := Object clone do(
  handleSocket := method(aSocket,
    aSocket streamReadNextChunk
    request := aSocket readBuffer betweenSeq("GET ", " HTTP") prependSeq(".")
    request = if(request == "./", "./index.html", request)
    request println
    f := File with(request)
    if(f exists,
      aSocket streamWrite("HTTP/1.1 200 OK\n\n"); f streamTo(aSocket),
      aSocket streamWrite("HTTP/1.1 404 Not Found\n\nNot Found\n")
    )
    aSocket close
  )
)

WebServer := Server clone do(
  port := System getEnvironmentVariable("PORT")
  port = if(port == nil, 5000, port asNumber)
  setPort(port)
  "Starting on port: #{port}" interpolate println
  handleSocket := method(aSocket,
    WebRequest clone asyncSend(handleSocket(aSocket))
  )
)

WebServer start
