-module (index).
-include_lib ("nitrogen/include/wf.hrl").
-compile(export_all).

main() -> #template { file="./templates/wildfire.html" }.

title() -> "Chatroom".

headline() -> "Comet Chatroom".

left() -> 
    [ 
	"<h2 style='color:#000;'>\"Wildfire Rocks\" Counter!!</h2>",
	#panel{id=success,body=""}
    ].

right() ->
    Body=[
        #span { text="Your chatroom name: " }, 
        #textbox { id=userNameTextBox, text="Anonymous", style="width: 100px;", next=messageTextBox },

        #p{},
        #panel { id=chatHistory, class=chat_history },

        #p{},
        #textbox { id=messageTextBox, style="width: 70%;", next=sendButton, text="wildfire rocks" },
        #button { id=sendButton, text="Send", postback=chat }
    ],

    % Start a process to listen for messages,
    % and then tell the chatroom that we would like to join.
    wf:comet_global(fun() -> chat_loop() end, chatroom),

    Body.


event(chat) ->
    Username = wf:q(userNameTextBox),
    Message = wf:q(messageTextBox),
    wf:send_global(chatroom, {message, Username, Message}),
    wf:wire("obj('messageTextBox').focus(); obj('messageTextBox').select();");

event(_) -> ok.

wildfire_rocks(true) -> wf:insert_bottom(success,"<img src='/images/wildfireapp-logo.png' style='padding-right:5px;'/>");
wildfire_rocks(false) -> "".

chat_loop() ->
    receive 
        'INIT' ->
            %% The init message is sent to the first process in a comet pool.
            Terms = [
                #p{},
                #span { text="You are the only person in the chat room.", class=message }
            ],
            wf:insert_bottom(chatHistory, Terms),
            wf:flush();

        {message, Username, Message} ->
            %% We got a message, so show it!
            Terms = [
                #p{},
                #span { text=Username, class=username }, ": ",
                #span { text=Message, class=message }
            ],
	    wildfire_rocks(string:str(Message, "wildfire rocks") > 0),
            wf:insert_bottom(chatHistory, Terms),
            wf:wire("obj('chatHistory').scrollTop = obj('chatHistory').scrollHeight;"),
            wf:flush()
    end,
    chat_loop().	


