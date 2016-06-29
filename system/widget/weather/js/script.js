var apiKey = "1a9c56c7cf5f6910780a6880ccae4b05";

function getZipCode(location, callback) {
	//If it's a cityid, we bypass the first step
	if ($.isNumeric(location)) {
		cityid_request(location, callback)
	//If they use a normal location
	} else {
    var currentWeatherUri = "http://api.openweathermap.org/data/2.5/weather?APPID=" + apiKey;
		$.get(currentWeatherUri + "&q=" + encodeURIComponent(location) + "&units=metric", function(locationData) {
			// Gets the cityId && Caches Location Name
			localStorage.tekukur_location = $(locationData).children().filterNode("name").text()//locationData.name 
			if (locationData.id) {
				callback(locationData)
			} else {
				callback()
			}
		})
	}
}

function getWeatherData(currentData, callback) {
  if (typeof currentData == 'string')
    currentData = JSON.parse(currentData)
  var weatherForecastUri = "http://api.openweathermap.org/data/2.5/forecast/daily?APPID=" + apiKey;
	$.ajax({
		url: weatherForecastUri + "&id=" + currentData.id,
		success: function(data) {
			$('#errorMessage').fadeOut(350)
      data.current = currentData;
      callback(data);
		},
		error: function(data) {
			if (data.status === 0) {
				showError('network');
			}
		}
	});
}

function suffix(sunrise, sunset) {
  sunrise *= 1000
  sunset *= 1000
  var now = new Date().valueOf();
  if (now >= sunrise && now < sunset)
    return "-d"
  return "-n"
}

function generateStats(data, callback) {
	//Weather Object
	weather = {}
  var current = data.current;
  
  if (!current || !current.main)
    return show_settings("location")

	//Location
	weather.city = city.name;
	weather.country = city.country;
	
    //Temperature
	weather.temperature = (current.main.temp) * 1.8 + 32 // °F = °C × 1,8 + 32
	weather.temperatureUnit = "F"

	//Wind
	weather.windUnit = 'm/s'
	weather.windSpeed = (current.wind.speed)
	weather.windDirection = current.wind.direction

	//Humidity
	weather.humidity = current.main.humidity 

	//Weekly Weather
	weekArr = data.list
	weather.week = []
	for (var i=0; i<5; i++) {
		weather.week[i] = {}
		weather.week[i].day = new Date(weekArr[i].dt * 1000).toString().split(' ')[0]
		weather.week[i].code = weekArr[i].weather[0].id + suffix(current.sys.sunrise, current.sys.sunset)
		weather.week[i].low = (weekArr[i].temp.max - 273.15) * 1.8 + 32
		weather.week[i].high = (weekArr[i].temp.min - 273.15) * 1.8 + 32
	}

	//Current Weather
  var currentWeather = current.weather[0] || {}
	weather.code = currentWeather.id + suffix(current.sys.sunrise, current.sys.sunset)
	if (callback) {
		callback(weather)
	}
}

function render(location){
	$('.border .sync').addClass('busy');
	$(".border .settings").show()

	getWeatherData(location, function(currentdata) {
		generateStats(currentdata, function(weather) {
      localStorage.tekukur_location = currentdata.city.name
			$('#city span').text(localStorage.tekukur_location)
			$("#icon").removeClass()
      $("#icon").addClass("owf")
      $("#icon").addClass("owf-" + weather.code) // todo night and day

			//Sets initial temp as Fahrenheit
			var temp = weather.temperature
			if (localStorage.tekukur_measurement == "c") {
				temp = Math.round((weather.temperature -32)/1.8)	// °C = (°F − 32) / 1,8
				$("#temperature").text(temp + " °C")
			} else if (localStorage.tekukur_measurement == "k") {
				temp = Math.round((weather.temperature  + 459.67)/1.8) 	// K = (°F + 459,67) / 1,8
				$("#temperature").text(temp + " K")
			} else {
				temp = Math.round((weather.temperature))
				$("#temperature").text(temp + " °F")
			}
			document.title = temp

			var windSpeed = weather.windSpeed * 2.236936292054  // 1 ms = 2.236936292054 mph
			if (localStorage.tekukur_speed != "mph") {
				//Converts to either kph or m/s
				windSpeed = (localStorage.tekukur_speed == "kph") ? Math.round(windSpeed * 1.609344) : Math.round(windSpeed * 4.4704) /10
			}
			windSpeed = windSpeed.toPrecision(2)

			$("#windSpeed").text(windSpeed)
			$("#windUnit").text((localStorage.tekukur_speed == "ms") ? "m/s" : localStorage.tekukur_speed)
			$("#humidity").text(weather.humidity + " %")

			//Background Color
			background(weather.temperature)

			//Weekly Bro.
			for (var i=0; i<5; i++) {
				$('#' + i + ' .day').text(weather.week[i].day)
				$('#' + i + ' .code').addClass("owf").addClass("owf-" + weather.week[i].code)
				if (localStorage.tekukur_measurement == "c") {
					$('#' + i + ' .temp').html(Math.round((weather.week[i].high -32)/1.8) + "°<span>" + Math.round((weather.week[i].low -32)/1.8) + "°</span>")
				} else if (localStorage.tekukur_measurement == "k") {
					$('#' + i + ' .temp').html(Math.round((weather.week[i].high + 459.67)/1.8) + "<span>" + Math.round((weather.week[i].low + 459.67)/1.8) + "</span>")
				} else {
					$('#' + i + ' .temp').html(Math.round((weather.week[i].high )) + "°<span>" + Math.round((weather.week[i].low )) + "°</span>")
				}
			}

			//Show Icon
			$('.border .sync, .border .settings').css("opacity", "0.8")
			$('#actualWeather').fadeIn(350)
			$("#locationModal").fadeOut(350)
			// spin the thing for 500ms longer than it actually takes, because
			// most of the time refreshing is actually instant :)
			setTimeout(function() { $('.border .sync').removeClass('busy'); }, 1000)
		})
	})
}

function background(temp) {
	// Convert RGB array to CSS
	var convert = function(i) {
		// Array to RGB
		if (typeof(i) == 'object') {
			return 'rgb(' + i.join(', ') + ')';

		// Hex to array
		} else if (typeof(i) == 'string') {
			var output = [];
			if (i[0] == '#') i = i.slice(1);
			if (i.length == 3)	i = i[0] + i[0] + i[1] + i[1] + i[2] + i[2];
			output.push(parseInt(i.slice(0,2), 16))
			output.push(parseInt(i.slice(2,4), 16))
			output.push(parseInt(i.slice(4,6), 16))
			return output;
		}
	};

	// Get color at position
	var blend = function(x) {
		x = Number(x)
		var gradient = [{
			pos: 0,
			color: convert('#0081d3')
		}, {
			pos: 10,
			color: convert('#007bc2')
		}, {
			pos: 20,
			color: convert('#0071b2')
		}, {
			pos: 30,
			color: convert('#2766a2')
		}, {
			pos: 40,
			color: convert('#575591')
		}, {
			pos: 50,
			color: convert('#94556b')
		}, {
			pos: 60,
			color: convert('#af4744')
		}, {
			pos: 70,
			color: convert('#bb4434')
		}, {
			pos: 80,
			color: convert('#c94126')
		}, {
			pos: 90,
			color: convert('#d6411b')
		}, {
			pos: 100,
			color: convert('#e44211')
		}];

		var left = {
			pos: -1,
			color: false,
			percent: 0
		};
		var right = {
			pos: 101,
			color:  false,
			percent: 0
		};

		// Get the 2 closest stops to the specified position
		for (var i=0, l=gradient.length; i<l; i++) {
			var stop = gradient[i];
			if (stop.pos <= x && stop.pos > left.pos) {
				left.pos = stop.pos;
				left.color = stop.color;
			} else if (stop.pos >= x && stop.pos < right.pos) {
				right.pos = stop.pos;
				right.color = stop.color;
			}
		}

		// If there is no stop to the left or right
		if (!left.color) {
			return convert(right.color);
		} else if (!right.color) {
			return convert(left.color);
		}

		// Calculate percentages
		right.percent = Math.abs(1 / ((right.pos - left.pos) / (x - left.pos)));
		left.percent = 1 - right.percent;

		// Blend colors!
		var blend = [
			Math.round((left.color[0] * left.percent) + (right.color[0] * right.percent)),
			Math.round((left.color[1] * left.percent) + (right.color[1] * right.percent)),
			Math.round((left.color[2] * left.percent) + (right.color[2] * right.percent)),
		];
		return convert(blend);
	};

	//Sets Background Color
	if (localStorage.tekukur_color == "gradient") {
		var percentage = Math.round((temp - 45) *  2.2)
		$("#container").css("background", blend(percentage))
	} else {
		$("#container").css("background", "#" + localStorage.tekukur_color)
	}
}

// Converts Yahoo weather to icon font
function weather_code(a){var b={0:"(",1:"z",2:"(",3:"z",4:"z",5:"e",6:"e",7:"o",8:"3",9:"3",10:"9",11:"9",12:"9",13:"o",14:"o",15:"o",16:"o",17:"e",18:"e",19:"s",20:"s",21:"s",22:"s",23:"l",24:"l",25:"`",26:"`",27:"2",28:"1",29:"2",30:"1",31:"/",32:"v",33:"/",34:"v",35:"e",36:"v",37:"z",38:"z",39:"z",40:"3",41:"o",42:"o",43:"o",44:"`",45:"z",46:"o",47:"z",3200:"`"};return b[a]}

function weather_code(a) {
  return "0";
}

$(document).ready(function() {
	//Filters Proprietary RSS Tags
	jQuery.fn.filterNode = function(name){
		return this.filter(function(){
			return this.nodeName === name;
		});
	};

	//APP START.
	init_settings()
	if (!localStorage.tekukur || typeof localStorage.tekukur != "string") {
		show_settings("location")
	} else {
    try {
      JSON.parse(localStorage.tekukur)
    }
    catch(ex) {
      return show_settings("location")
    }
		//Has been run before
		render(localStorage.tekukur)

		setInterval(function() {
			console.log("Updating Data...")
			$(".border .sync").click()
		}, 600000)
	}
});

function init_settings() {

	//Prevents Dragging on certain elements
	$('.border .settings, .border .sync, .border .close, .border .minimize, #locationModal input, #locationModal .measurement span, #locationModal .speed span, #locationModal .loader, #locationModal a, #locationModal .color, #locationModal .btn, #errorMessage .btn, #city span, #locationModal img').mouseover(function() {
		document.title = "disabledrag"
	}).mouseout(function() {
		document.title = "enabledrag"
	}).click(function() {
		if ($(this).hasClass("close")) {
			document.title = 'close'
		} else if ($(this).hasClass("minimize")) {
			document.title = 'minimize'
		} else if ($(this).hasClass("settings")) {
			show_settings("all")
		} else if ($(this).hasClass("sync")) {
			render(localStorage.tekukur)
		}
	})

	//First Run
	var locationInput = $("#locationModal input")
	var typingTimer
	var doneTypingInterval = 1500

	//on keyup, start the countdown
	locationInput.keyup(function(){
	    typingTimer = setTimeout(doneTyping, doneTypingInterval)
	}).keydown(function(){
	//on keydown, clear the countdown
	    clearTimeout(typingTimer)
	});

	function doneTyping() {
		$("#locationModal .loader").attr("class", "loading loader").html("|")
		getZipCode(locationInput.val(), function(zipCode) {
			if (zipCode) {
        zipCode = JSON.stringify(zipCode);
				$("#locationModal .loader").attr("class", "tick loader").html("&#10003;").attr("data-code", zipCode)
			} else {
				$("#locationModal .loader").attr("class", "loader").html("&#10005;")
			}
		})
	}

	//This can only be run if there is a tick.
	$("#locationModal .loader").click(function() {
		if ($(this).hasClass("tick")) {
			localStorage.tekukur = $("#locationModal .loader").attr("data-code")
			render(JSON.parse(localStorage.tekukur))
			show_settings("noweather")
			setInterval(function() {
				console.log("Updating Data...")
				$(".border .sync").click()
			}, 600000)
		}
	})

	// Sets up localstorage
	localStorage.tekukur_measurement = localStorage.tekukur_measurement || "c"
	localStorage.tekukur_speed = localStorage.tekukur_speed || "kph"
	localStorage.tekukur_color =  localStorage.tekukur_color || "gradient"
	localStorage.tekukur_launcher = localStorage.tekukur_launcher || "checked"

	$('#locationModal .measurement [data-type=' + localStorage.tekukur_measurement + ']').addClass('selected')
	$('#locationModal .speed [data-type=' + localStorage.tekukur_speed + ']').addClass('selected')

	//Sets up the Toggle Switches
	$('#locationModal .toggleswitch span').click(function() {
		$(this).parent().children().removeClass('selected')
		localStorage.setItem("tekukur_" + $(this).parent().attr("class").replace("toggleswitch ", ""), $(this).addClass('selected').attr("data-type"))
		$(".border .settings").hide()
	})

	//Color thing
	$('.color span').click(function() {
		localStorage.tekukur_color = $(this).attr("data-color")
		background(null)
	})
    $('.color span[data-color=gradient]').click(function() {
        $(".border .settings").hide()
    })
	

	if (localStorage.tekukur_launcher == "checked") {
		$('#locationModal .launcher input').attr("checked", "checked")
		document.title = "enable_launcher"
	}
	$('#locationModal .launcher input').click(function() {
		localStorage.tekukur_launcher = $('#locationModal .launcher input').attr("checked")
		if (localStorage.tekukur_launcher == "checked") {
			document.title = "enable_launcher"
		} else {
			document.title = "disable_launcher"
		}
	})

	//Control CSS.
	$("span[data-color]:not([data-color=gradient])").map(function() { $(this).css('background', '#' + $(this).attr("data-color")) })

	/* Error Message Retry Button */
	$('#errorMessage .btn').click(function() {
		render(localStorage.tekukur)
	})

}
function show_settings(amount) {

	if (amount == 'all') {
		$("#locationModal .full").show()
		$("#locationModal .credits").hide()
	} else if (amount == 'location') {
		$("#locationModal .full").hide()
		$("#locationModal .credits").hide()
	}
	$('.btn[tag="credits"]').click(function() {
		$("#locationModal .input, #locationModal .full, .settings, .sync").hide()
		$("#locationModal .credits").fadeIn(350)
	})
	$('#locationModal .credits img').click(function() {
		$("#locationModal .credits").fadeOut(350)
		$("#locationModal .input, #locationModal .full, .settings, .sync").fadeIn(350)
	})
	//Show the Modal
	$("#locationModal").fadeToggle(350)
	if (amount != "noweather") {
		$("#actualWeather").fadeToggle(350)
	}
}
function showError() {
	$('#actualWeather').fadeOut(350)
	$('#errorMessage').fadeIn(350)
}
function updateTitle(val) {
	document.title = "o" + val
	localStorage.app_opacity = val
}
function opacity() {
	//On first run, opacity would be 0.8
	if (localStorage.getItem("app_opacity") === null) {
		localStorage.app_opacity = 0.8
	}
	$('input[type=range]').val(localStorage.app_opacity)
	document.title = "o" + localStorage.app_opacity
	// document.title = enable_drag
}
