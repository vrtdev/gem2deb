require 'test_helper'
require 'gem2deb/gem2tgz'
require 'gem2deb/dh_make_ruby'
require 'gem2deb/dh_ruby'
require 'gem2deb/setup_rb_installer'
require 'rbconfig'

class SetupRbInstallerTest < Gem2DebTestCase

  one_time_setup do
    build(SIMPLE_SETUPRB_NAME, SIMPLE_SETUPRB_DIRNAME)
  end

  dirname = SIMPLE_SETUPRB_DIRNAME
  package = "ruby-simplesetuprb"

  context 'installing native extension with setuprb' do
    SUPPORTED_VERSION_NUMBERS.each do |version_number|
      vendorarchdir = VENDOR_ARCH_DIRS['ruby' + version_number]
      target_so = "#{vendorarchdir}/simplesetuprb.so"
      should "install native extension for Ruby #{version_number} for #{package}" do
        assert_installed dirname, package, target_so
      end
      should "link #{target_so} against libruby#{version_number} for #{package}" do
        installed_so = installed_file_path(dirname, package, target_so)
        assert_match /libruby-?#{version_number}/, `ldd #{installed_so}`
      end
    end
  end

  context 'test pre-install.rb hook' do
    target_file = "/usr/lib/ruby/vendor_ruby/simplesetuprb/generated.rb"
    should "install file generated by pre-install.rb hook" do
      assert_installed dirname, package, target_file
    end
  end

  protected

  def self.build(pkgname, source_package)
    package_path = File.join(tmpdir, 'ruby-' + source_package)
    tarball =  File.join(tmpdir, source_package + '.tar.gz')
    source_dir = File.join(tmpdir, source_package)

    FileUtils.cp_r("test/sample/#{pkgname}", source_dir)
    # Here, copy setup.rb to the source dir.
    FileUtils.cp("/usr/lib/ruby/vendor_ruby/setup.rb", 
                 source_dir)
    system("tar czf #{tarball} -C#{tmpdir} #{source_package}")
    FileUtils.rm_rf(File.join(tmpdir, source_dir))
    Gem2Deb::DhMakeRuby.new(tarball).build

    dh_ruby = Gem2Deb::DhRuby.new
    dh_ruby.installer_class = Gem2Deb::SetupRbInstaller
    dh_ruby.verbose = false

    ENV['RUBYLIB'] = File.join(File.dirname(__FILE__), '../../lib')
    silence_stream(STDOUT) do
      silence_stream(STDERR) do
        Dir.chdir(package_path) do
          # This sequence tries to imitate what dh will actually do
          dh_ruby.clean
          dh_ruby.configure
          dh_ruby.build
          dh_ruby.install([File.join(package_path, 'debian', 'tmp')])
        end
      end
    end
  end

end
