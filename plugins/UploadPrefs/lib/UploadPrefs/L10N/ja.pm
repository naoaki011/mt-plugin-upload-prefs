package UploadPrefs::L10N::ja;

use strict;
use base 'UploadPrefs::L10N::en_us';
use vars qw( %Lexicon );

%Lexicon = (
    'Set default values and actions of file upload.' => 'ファイルアップロード時のデフォルト値と動作を変更します。',
    'Upload Folder Base' => 'アップロードフォルダ',
    'A folder within the site root to place your assets (eg assets/).' => 'デフォルのでのアイテムのアップロード先 (例 assets/)',
    'Name of Site Root' => 'サイトルートの名前',
    'Change text of &quot;Site Root&quot; in display.' => '”サイトルート”を別名で表示します。',
    'Remove date-based folder option' => '日付ベースのオプションを削除',
    'Check this box to Remove date-based directory appear.' => 'ここにチェックを入れると、アップロード先プルダウンから日付ベースの候補が削除されます。',
    'Disabled for user change upload path.' => 'ユーザーがパスの変更を出来なくする',
    'Check this box to User won\'t change upload path.' => 'ここにチェックを入れると、アップロード先のプルダウンとフォルダ入力が出来なくになります。',
    'Enabled for admin change upload path.' => '管理者のみアップロード先を変更できる',
    'Check this box to Admin will change upload path.' => 'ここにチェックを入れると、管理者のみアップロード先の変更が可能になります。',
    'Disabled Upload Site Root' => 'サイトルートへのアップロードを禁止',
    'Check this box to Never Upload Site Root.' => 'ここにチェックを入れると、サイトルートへのアップロードが出来なくなります。',
);

1;
