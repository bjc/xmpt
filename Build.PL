use Module::Build;

my $build = new Module::Build(dist_name => 'xmpt',
			      dist_version_from => 'xmpt',
			      script_files => ['xmpt']);
$build->create_build_script;
