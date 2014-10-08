<?php
/*
Plugin Name: Email Obfuscate Button
Description: Adds a button to the TinyMCE to wrap an email address with a shortcode using the Email Obfuscate Shortcode plugin.
Version: 1.0
Author: fsl
*/

/*  Copyright 2014

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; version 2 of the License (GPL v2) only.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
*/

// create and register button and javascript
add_filter('mce_external_plugins', 'email_link_register');
add_filter('mce_buttons', 'email_link_add_button', 0);
//add_shortcode( 'sf_email', 'email_shortcode' );


function email_link_add_button($buttons) {
	array_push($buttons, 'separator', 'email_link_name');
	return $buttons;
}

function email_link_register($plugin_array) {
	$email_url = plugins_url( '/email-obfuscate-button.js', __FILE__ );
	$plugin_array['email_link_name'] = $email_url;
	return $plugin_array;
}

// Add shortcode function

//function email_shortcode( $atts, $content = null ) {
//	return '<a class="email-link" href="mailto:'.antispambot($content).'" title="Email" target="_blank">'.antispambot($content).'</a>';
//		return $email_ssc;
//}

