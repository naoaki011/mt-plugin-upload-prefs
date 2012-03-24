package UploadPrefs::Plugin;

use MT 5.1;
use warnings;
use strict;

sub xfm_src {
  my ($cb, $app, $tmpl) = @_;
  my $blog = $app->blog or return;
  return unless ((MT->version_number >= 5.13) && (MT->version_number < 5.2));
  my $plugin = MT->component("UploadPrefs");
  my $upload_folder_base = $plugin->get_config_value('upload_folder_base' , 'blog:' . $blog->id ) || '';
  my $name_of_siteroot = $plugin->get_config_value('name_of_siteroot' , 'blog:' . $blog->id ) || '<__trans phrase="Site Root">';
  my $change_path_disabled = $plugin->get_config_value('change_path_disabled' , 'blog:' . $blog->id ) || 0;
  unless ($change_path_disabled) { 
    my $date_based_default = $plugin->get_config_value(
      'date_based_default' , 'blog:' . $blog->id ) || 0;
    if ($date_based_default) {
      my $old = <<'HTML';
     <mt:loop name="extra_paths">
       <option value="<mt:if name="enable_archive_paths">0<mt:else>1</mt:if>" middle_path="<mt:var name="path" escape="html">"<mt:if name="selected"> selected="selected"</mt:if>><mt:var name="label" escape="html"></option>
     </mt:loop>
     </mt:if>
     </select> / <input type="text" name="extra_path" id="extra_path" class="text path" value="<mt:var name="extra_path" escape="html">" />
HTML
      $old = quotemeta($old);
      my $new = <<"HTML";
     </mt:if>
     </select> / <input type="text" name="extra_path" id="extra_path" class="text path" value="$upload_folder_base" />
HTML
      $$tmpl =~ s!$old!$new!;
    }
    else {
      my $old = <<'HTML';
     </select> / <input type="text" name="extra_path" id="extra_path" class="text path" value="<mt:var name="extra_path" escape="html">" />
HTML
      $old = quotemeta($old);
      my $new = <<"HTML";
     </select> / <input type="text" name="extra_path" id="extra_path" class="text path" value="$upload_folder_base" />
HTML
      $$tmpl =~ s!$old!$new!;
    }
    $$tmpl =~ s!<__trans phrase="Site Root">!$name_of_siteroot!;
  }
  else {
    my $old = <<'HTML';
     <select name="site_path" id="site_path" onchange="setExtraPath(this)">
       <option value="1">&#60;<__trans phrase="Site Root">&#62;</option>
     <mt:if name="enable_archive_paths">
       <option value="0"<mt:if name="archive_path"> selected="selected"</mt:if>>&#60;<__trans phrase="Archive Root">&#62;</option>
     </mt:if>
     <mt:if name="extra_paths">
     <mt:loop name="extra_paths">
       <option value="<mt:if name="enable_archive_paths">0<mt:else>1</mt:if>" middle_path="<mt:var name="path" escape="html">"<mt:if name="selected"> selected="selected"</mt:if>><mt:var name="label" escape="html"></option>
     </mt:loop>
     </mt:if>
     </select> / <input type="text" name="extra_path" id="extra_path" class="text path" value="<mt:var name="extra_path" escape="html">" />
     <a href="javascript:void(0);" mt:command="open-folder-selector" class="toggle-link"><__trans phrase="Choose Folder"></a>
HTML
    $old = quotemeta($old);
    my $new = <<"HTML";
     <input type="hidden" name="site_path" value="1" />$name_of_siteroot&nbsp;&frasl;&nbsp;
     <input type="text" name="extra_path" id="extra_path" class="extra-path" readonly="readonly" value="$upload_folder_base" style="width:20em;" />
HTML
    $$tmpl =~ s!$old!$new!;
  }

  my $ua = $ENV{'HTTP_USER_AGENT'};
  if ($ua =~ /(Firefox\/|Chrome\/|Opera\/)/) {
    my $old = <<'HTML';
<form method="post" enctype="multipart/form-data" action="<mt:var name="script_url">" id="upload-form" onsubmit="return validate(this)">
HTML
    $old = quotemeta($old);
    my $new = <<"HTML";
<div id="preview_block" style="display:none;">
  <img id="image_preview" src="#" style="position:absolute;border:1px solid #ccc;padding:5px;" width="150" />
</div>
<form method="post" enctype="multipart/form-data" action="<mt:var name="script_url">" id="upload-form" onsubmit="return validate(this)">
HTML
    $$tmpl =~ s!$old!$new!;
    $old = <<'HTML';
<input type="file" name="file" id="file" />
HTML
    $old = quotemeta($old);
    my $new = <<"HTML";
<input type="file" name="file" id="file" />
  <script>
  jQuery(document).ready( function () {
   jQuery('#file').change(function() {
    readURL(this);
   });
  });
  function readURL(input) {
   if (input.files && input.files[0]) {
    var reader = new FileReader();
    reader.onload = function (e) {
     jQuery('#image_preview').attr('src', e.target.result);
     jQuery('#preview_block').attr('style', 'display:block;margin-left:640px;');
    };
    reader.readAsDataURL(input.files[0]);
   }
  }
  </script>
  <style type="text/css">
  #main-content div {
   width: 620px;
  }
  </style>
HTML
    $$tmpl =~ s!$old!$new!;
  }

  1;
}

1;
