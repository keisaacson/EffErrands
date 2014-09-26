
// $('.add').on("click", function(){
// $('.add').text("Add my errand!");

// });




 $(document).ready(function(){
 	$('.location').on('click', function() {
 		if ($('#start_name').val().length==0 && $('#start_address').val().length==0) {
 			$('.error.start_name').show();
 			$('.error.start_address').show();
 			return false;
 		} 

 		else if ($('#start_name').val().length==0) {
 			$('.error.start_name').show();
 			$('.error.start_address').hide();
 			return false;
 		} 
 		else if ($('#start_address').val().length==0) {
 			$('.error.start_address').show();
 			$('.error.start_name').hide();
 			return false;


 		} else if ($('#start_address').val().length!=0 && $('#start_name').val().length!=0) {
 			$('.error.start_address').hide();
 			$('.error.start_name').hide();
 			return true;
 		}

 	});

 	$('.add').on('click', function() {
 		if ($('#dest_name').val().length==0 && $('#dest_address').val().length==0) {
 			$('.error.dest_name').show();
 			$('.error.dest_address').show();
 			return false;
 		} 

 		else if ($('#dest_name').val().length==0) {
 			$('.error.dest_name').show();
 			$('.error.dest_address').hide();
 			return false;
 		} 
 		else if ($('#dest_address').val().length==0) {
 			$('.error.dest_address').show();
 			$('.error.dest_name').hide();
 			return false;


 		} else if ($('#dest_address').val().length!=0 && $('#dest_name').val().length!=0) {
 			$('.error.dest_address').hide();
 			$('.error.dest_name').hide();
 			return true;
 		}

 	});

 	$('.find_route').on('click', function() {
 		if ($('#start_name').val().length==0 
 			|| $('#start_address').val().length==0
 			|| $('#dest_name').val().length==0 
 			|| $('#dest_address').val().length==0 ) {
 			$('.error.start_name').show();
 			$('.error.start_address').show();
 			return false;
 		} 

 		});

	// $(function(){
	// 	$('.accordion_up').click(function(){
	// 		$(this).slideUp("slow", function(){

	// 		});
	// 	});
			
	// });

	// $(function(){
	// 	$('.accordion_down').click(function(){
	// 		$($(this).next()).slideDown("slow", function(){

	// 		});
	// 	});
			
	// });
	
	$($('.accordion_down').next()).hide();
	// var label = true
	
	// make boolean value for hiding / showing label "toggle-prompt"

	$(function(){
		$('.accordion_down').click(function(){
			$($(this).next()).slideToggle("slow", function(){

			});
		});
			
	});



	// 	$(function(){
	// 	$('.accordion').click(function(){
	// 		$(this).slideDown("slow", function(){

	// 		});
	// 	});
			
	// });
	// });
 	// $('.find_route').on('click', function() {
 	// 	if ($('#dest_name').val().length==0 && $('#dest_address').val().length==0) {
 	// 		$('.error.dest_name').show();
 	// 		$('.error.dest_address').show();
 	// 		return false;
 	// 	} 
 	// });

});