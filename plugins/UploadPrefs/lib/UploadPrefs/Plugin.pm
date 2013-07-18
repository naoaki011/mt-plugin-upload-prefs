package UploadPrefs::Plugin;

use MT 5.1;
use warnings;
use strict;

sub _asset_src_upload {
  my ($cb, $app, $tmpl) = @_;
  my $blog = $app->blog or return;
  return unless ((MT->version_number >= 5) && (MT->version_number < 6.1));
  my $user = current_user( $app ) or return;
  my $plugin = MT->component("UploadPrefs");

  my $admin_only = $plugin->get_config_value('admin_only' , 'blog:' . $blog->id ) || 0;
  my $is_admin;
  if ($admin_only) {
    $is_admin = $user->is_superuser ? 1
                                    : $app->can_do('administer_blog') ? 2
                                                                      : 0;
    #MT->log('admin: ' . $is_admin);
  }

  my $upload_folder_base = $plugin->get_config_value('upload_folder_base' , 'blog:' . $blog->id ) || '';
  my %f;
  my($sec, $min,  $hour, $day, $mon, $year, $wday, $yday, $isdst) = localtime;
  $f{'Y'} = sprintf('%04d', ($year + 1900));
  $f{'y'} = substr($f{'Y'}, 2, 2);
  $f{'b'} = qw/jan feb mar apr may jun jul aug sep oct nov dec/[$mon];
  $f{'m'} = sprintf('%02d', (++$mon));
  $f{'d'} = sprintf('%02d', ($day));
  $f{'j'} = sprintf('%03d', ($yday));
  $f{'H'} = sprintf('%02d', ($hour));
  $f{'M'} = sprintf('%02d', ($min));
  $f{'S'} = sprintf('%02d', ($sec));
  $f{'w'} = $wday;
  $f{'a'} = qw/sun mon tue wed thu fri sat/[$wday];

  my $modifier;
  $modifier = quotemeta('%Y');
  $upload_folder_base =~ s!$modifier!$f{'Y'}!;
  $modifier = quotemeta('%y');
  $upload_folder_base =~ s!$modifier!$f{'y'}!;
  $modifier = quotemeta('%m');
  $upload_folder_base =~ s!$modifier!$f{'m'}!;
  $modifier = quotemeta('%b');
  $upload_folder_base =~ s!$modifier!$f{'b'}!;
  $modifier = quotemeta('%d');
  $upload_folder_base =~ s!$modifier!$f{'d'}!;
  $modifier = quotemeta('%j');
  $upload_folder_base =~ s!$modifier!$f{'j'}!;
  $modifier = quotemeta('%H');
  $upload_folder_base =~ s!$modifier!$f{'H'}!;
  $modifier = quotemeta('%M');
  $upload_folder_base =~ s!$modifier!$f{'M'}!;
  $modifier = quotemeta('%S');
  $upload_folder_base =~ s!$modifier!$f{'S'}!;
  $modifier = quotemeta('%w');
  $upload_folder_base =~ s!$modifier!$f{'w'}!;
  $modifier = quotemeta('%a');
  $upload_folder_base =~ s!$modifier!$f{'a'}!;

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
    if (($is_admin)||($admin_only)) {


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
      my $new;
      $new = <<"HTML";
     <input type="hidden" name="site_path" value="1" />$name_of_siteroot&nbsp;&frasl;&nbsp;
     <input type="text" name="extra_path" id="extra_path" class="extra-path" readonly="readonly" value="$upload_folder_base" style="background-color:#ccc;width:16em;" />
     <script type="text/javascript">
       jQuery(document).ready( function () {
         jQuery('#site_path-field .hint').hide();
       });
     </script>
HTML
      $$tmpl =~ s!$old!$new!;
    }
  }

  my $ignore_root = $plugin->get_config_value('ignore_root_path' , 'blog:' . $blog->id ) || 0;
  if ($ignore_root) {
    my $old = <<'HTML';
  <div class="actions-bar">
HTML
    $old = quotemeta($old);
    my $new = <<"HTML";
  <script type="text/javascript">
    jQuery(document).ready( function () {
     jQuery('#upload-form').validate({
      rules: {
       extra_path: "required"
      },
      messages: {
       extra_path: "<__trans_section component="UploadPrefs"><__trans phrase="Ignore BlankPath."></__trans_section>"
      }
     });
    });
  </script>
  <div class="actions-bar">
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
  <img id="image_preview" src="#" style="position:absolute;border:1px solid #ccc;padding:5px;background-color:#fff;" width="150" />
</div>
<form method="post" enctype="multipart/form-data" action="<mt:var name="script_url">" id="upload-form" onsubmit="return validate(this)">
HTML
    $$tmpl =~ s!$old!$new!;
    $old = <<'HTML';
<input type="file" name="file" id="file" />
HTML
    $old = quotemeta($old);
    $new = <<"HTML";
<input type="file" name="file" id="file" />
  <script>
  jQuery(document).ready( function () {
   jQuery('#file').change(function() {
    jQuery('#preview_block').attr('style', 'display:none;');
    if(jQuery('#file').val().match(/\\.(jpe?g|gif|png)\$/i)){
     readURL(this);
    }
   });
  });
  function readURL(input) {
   if (input.files && input.files[0]) {
    var reader = new FileReader();
    reader.onload = function (e) {
     jQuery('#image_preview').attr('src', e.target.result);
<mt:if name="dialog">
     jQuery('#preview_block').attr('style', 'display:block;margin-left:460px;margin-top:-40px;padding-bottom:40px;');
<mt:else>
     jQuery('#preview_block').attr('style', 'display:block;margin-left:640px;');
</mt:if>
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

sub current_user {
    my $app = shift || MT->instance();
    my $user;
    eval { $user = $app->user };
    unless ( $@ ) {
        return $user if defined $user;
    }
    return undef;
}

sub include_multibyte {
    my ( $file_path ) = @_;
    my $file_basename = File::Basename::basename( $file_path );
    my $encoded = encode_url( $file_basename );
    unless ( $file_basename eq $encoded ) {
        return 1;
    }
    return 0;
}

1;
