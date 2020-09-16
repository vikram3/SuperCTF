extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	$Control/Enter_Button.connect("pressed", self, "_enter_pressed");
	$Control/Cancel_Button.connect("pressed", self, "_cancel_pressed");
	$Control/Background_Button.connect("pressed", self, "_cancel_pressed");
	$Login_HTTP.connect("request_completed", self, "_Login_HTTP_Completed");

func _enter_pressed():
	var n = $Control/Name_LineEdit.text;
	var password = $Control/Password_LineEdit.text;
	
	
	if !("a" + $Control/Name_LineEdit.text).is_valid_identifier():
		$Control/Warning_Text.bbcode_text = '[color=red][center]Name can only contain letters, numbers, and "-"';
		return;
	if $Control/Password_LineEdit.text.length() < 8:
		$Control/Warning_Text.bbcode_text = '[color=red][center]Password must be at least 8 characters long';
		return;
	
	if $Login_HTTP.get_http_client_status() == 0:
		$Control/Warning_Text.bbcode_text = "[color=black][center]Loading...";
		var query = "?name=" + str(n);
		var body = '{"password" : "' + str($Control/Password_LineEdit.text) + '"}';
		$Login_HTTP.request(Globals.mainServerIP + "loginUser" + query, ["authorization: Bearer " + Globals.userToken],true,2,body);

func _Login_HTTP_Completed(result, response_code, headers, body):
	if response_code == 200:
		var json = JSON.parse(body.get_string_from_utf8())
		$Control/Warning_Text.bbcode_text = "[color=green][center]Logged In!";
		var token = json.result.token;
		if(token):
			Globals.userToken = token;
			Globals.write_save_data();
			get_parent().set_view(get_parent().VIEW_MAIN);
		else:
			$Control/Warning_Text.bbcode_text = "[color=red][center]A serious error(9296) occurred. Please tell us on discord";
		yield(get_tree().create_timer(0.5), "timeout");
		self.call_deferred("queue_free");
		return;
	elif response_code == 404:
		$Control/Warning_Text.bbcode_text = "[color=red][center]Invalid username/password";
		return;
	$Control/Warning_Text.bbcode_text = "[color=red][center]A serious error(2757) occurred. Please tell us on discord";
	return;

func _cancel_pressed():
	call_deferred("queue_free");