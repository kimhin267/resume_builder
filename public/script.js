$(document).ready(function(){
	$('#addSchoolbtn').click(function(){         
		$('#addSchool').append("<br><br><br>\
			<div class='control-group'>\
				<label class='control-label'>School's name: </label>\
				<div class='controls'>\
					<input type='text' name='resume[school]'>\
				</div>	\
			</div>\
			\
			<div class='control-group'>\
				<label class='control-label'>City: </label>\
				<div class='controls'>\
					<input type='text' name='resume[school[[school_city]]]'>\
				</div>\
			</div>\
			\
			<div class='control-group'>\
				<label class='control-label'>State: </label>\
				<div class='controls'>\
					<input type='text' name='resume[school_state]'>\
				</div>\
			</div>	\
			\
			<div class='control-group'>\
				<label class='control-label'>Degree: </label>\
				<div class='controls'>\
					<input  type='text' name='resume[degree]'>\
				</div>\
			</div>\
			\
			<div class='control-group'>\
				<label class='control-label'>Graduation Date: </label>\
				<div class='controls'>\
					<input type='text' name='resume[graduation_date]'>\
				</div>\
			</div>	\
			\
			<div class='control-group'>\
				<label class='control-label'>Major: </label>\
				<div class='controls'>\
					<input type='text' name='resume[major]'>\
				</div>\
			</div>\
			\
			<div class='control-group'>\
				<label class='control-label'>GPA: </label>\
				<div class='controls'>\
					<input type='text' name='resume[gpa]'>\
				</div>\
			</div>"
		);     
	});
	$('#addJobbtn').click(function(){
		$('#addJob').append("<br><br><br><div class='control-group'>\
				<label class='control-label'>Company's Name: </label>\
				<div class='controls'>\
					<input type='text' name='resume[company_name]'>\
				</div>\
			</div>\
			\
			<div class='control-group'>\
				<label class='control-label'>Position: </label>\
				<div class='controls'>\
					<input type='text' name='resume[position]'>\
				</div>\
			</div>\
			\
			<div class='control-group'>\
				<!-- make into drop box -->\
				<label class='control-label'>Start date (month/year): </label>\
				<div class='controls'>\
					<input type='text' name='resume[job_start]'>\
				</div>\
			</div>\
			\
			<div class='control-group'>\
				<!-- make into drop box -->\
				<label class='control-label'>End date (month/year): </label>\
				<div class='controls'>\
					<input type='text' name='resume[job_end]'>\
				</div>\
			</div>	\
			\
			<div class='control-group'>\
				<label class='control-label'>Job experience: </label>\
				<div class='controls'>\
					<!--<input type='textarea' name='resume[job_skills]'>-->\
					<textarea class='span5' name='resume[job_skills]' placeholder='Max 200 characters.You can drag the bottom left corner to make text box larger.'></textarea>\
				</div>\
			</div>"
		);
	}); 
	$('#addOtherExpbtn').click(function(){
		$('#addOtherExp').append("<div class='control-group'>\
				<div class='controls'>\
					<textarea class='span5' name='resume[skills]' placeholder='Max 200 characters. You can drag the bottom left corner to make text box larger.'></textarea>\
				</div>\
			</div>"
		);
	});  
});
