function email_link_insert() {
	email_link_select = tinyMCE.activeEditor.selection.getContent();
    tinyMCE.activeEditor.selection.setContent('[email-obfuscate email="' + email_link_select + '"]');
}

(function() {

    tinymce.create('tinymce.plugins.email_link_insert', {

        init : function(ed, url){
            ed.addButton('email_link_name', {
                title : 'E-Mail vor Spamattacken schützen',
                onclick : function() {
                    ed.execCommand(
                        'mceInsertContent',
                        false,
                        email_link_insert()
                        );
                },
                image: url + "/img/email-link-button.png"
            });
        },
		getInfo : function() {
			return {
				longname:	'Email Obfuscate Button',
				author:		'fsl',
				authorurl:	'',
				infourl:	'',
				version:	"1.0"
			};
		}
	});

    tinymce.PluginManager.add('email_link_name', tinymce.plugins.email_link_insert);
    
})();
