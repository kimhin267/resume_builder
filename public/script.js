
$(document).ready(function(){
	var school_count = 0;
	var job_count = 0;
	var other_count = 0;

	$('#submit-button-resume-form').click(function() {
		$("#delete-front_end_error-form").remove();
		var validator = $("#validation").validate({
			/*messages: {
				$("input[name='resume[zip_code]']"): "Please enter a valid zip code."
			},*/
			highlight: function(label) {
			    $(label).closest('.control-group').addClass('error');
			},
			unhighlight: function(label) {
			     $(label).closest('.control-group').removeClass('error');
			},
  			invalidHandler: function() {
  				if (validator.numberOfInvalids() == 1){
	  				$("#front_end_error-form").append("<div class='error_message well well-small resume-form' id='delete-front_end_error-form'\
	  				 id='front_end_error'> Your form contain "+ validator.numberOfInvalids() + " invalid field,\
	    			see highlighted field.</div>");
  				}
 				else{
 					$("#front_end_error-form").append("<div class='error_message well well-small resume-form' id='delete-front_end_error-form'\
	  				 id='front_end_error'> Your form contains   "+ validator.numberOfInvalids() + " invalid fields,\
	    			see highlighted fields.</div>");
 				}
    			$("#front_end_error").text();
    			
    			return false;
    		}
		});
	});

	

	$('#addSchoolbtn').click(function(){         
		school_count += 1;
		$('#addSchool').append("<br><br><br>\
			<div class='control-group'>\
				<label class='control-label'>School's name: </label>\
				<div class='controls'>\
					<input type='text' name='education[" + school_count + "][school]'>\
				</div>	\
			</div>\
			\
			<div class='control-group'>\
				<label class='control-label'>City: </label>\
				<div class='controls'>\
					<input type='text' name='education[" + school_count + "][school_city]'>\
				</div>\
			</div>\
			\
			<div class='control-group'>\
				<label class='control-label'>State: </label>\
				<div class='controls'>\
					<input type='text' name='education[" + school_count + "][school_state]'>\
				</div>\
			</div>	\
			\
			<div class='control-group'>\
				<label class='control-label'>Degree: </label>\
				<div class='controls'>\
					<input  type='text' name='education[" + school_count + "][degree]'>\
				</div>\
			</div>\
			\
			<div class='control-group'>\
				<label class='control-label'>Graduation Date: </label>\
				<div class='controls'>\
					<input type='text' name='education[" + school_count + "][graduation_date]'>\
				</div>\
			</div>	\
			\
			<div class='control-group'>\
				<label class='control-label'>Major: </label>\
				<div class='controls'>\
					<input type='text' name='education[" + school_count + "][major]'>\
				</div>\
			</div>\
			\
			<div class='control-group'>\
				<label class='control-label'>GPA: </label>\
				<div class='controls'>\
					<input type='text' name='education[" + school_count + "][gpa]'>\
				</div>\
			</div>"

		);     
	});
	$('#addJobbtn').click(function(){
		job_count += 1;
		$('#addJob').append("<br><br><br><div class='control-group'>\
				<label class='control-label'>Company's Name: </label>\
				<div class='controls'>\
					<input type='text' name='job["+ job_count +"][company_name]'>\
				</div>\
			</div>\
			\
			<div class='control-group'>\
				<label class='control-label'>Position: </label>\
				<div class='controls'>\
					<input type='text' name='job["+ job_count +"][position]'>\
				</div>\
			</div>\
			\
			<div class='control-group'>\
				<!-- make into drop box -->\
				<label class='control-label'>Start date (month/year): </label>\
				<div class='controls'>\
					<input type='text' name='job["+ job_count +"][job_start]'>\
				</div>\
			</div>\
			\
			<div class='control-group'>\
				<!-- make into drop box -->\
				<label class='control-label'>End date (month/year): </label>\
				<div class='controls'>\
					<input type='text' name='job["+ job_count +"][job_end]'>\
				</div>\
			</div>	\
			\
			<div class='control-group'>\
				<label class='control-label'>Job experience: </label>\
				<div class='controls'>\
					<!--<input type='textarea' name='resume[job_skills]'>-->\
					<textarea class='span5' name='job["+ job_count +"][job_skills]' placeholder='Max 200 characters.You can drag the bottom left corner to make text box larger.'></textarea>\
				</div>\
			</div>"
		);
	}); 
	$('#addOtherExpbtn').click(function(){
		other_count += 1;
		$('#addOtherExp').append("<div class='control-group'>\
				<div class='controls'>\
					<textarea class='span5' name='otherskill["+ other_count +"][skills]' placeholder='Max 200 characters. You can drag the bottom left corner to make text box larger.'></textarea>\
				</div>\
			</div>"
		);
	});
});


