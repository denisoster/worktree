require 'fileutils'
require 'logger'
require 'yaml'

module WorkTree
  class Add
    def initialize(branch)
      @branch = branch
    end

    def do!
      raise "Folder #{@branch} already exists!" if Dir.exist?("#{Dir.pwd}/#{@branch}")
      raise 'No master repo found!' unless Dir.exist?("#{master_repo}/.git")

      git = Git.open("#{Dir.pwd}/master", log: Logger.new(STDOUT))

      git.fetch('upstream')
      git.pull('upstream', 'master')

      Dir.chdir('master') do
        # you can set branch to make worktree from
        # worktree add some-branch upstream/didww
        TTY::Command.new.run "git worktree add -b #{@branch} ../#{@branch} #{branch_remote}"
        copy_files
        Dir.chdir("../#{@branch}") do
          create_exrc if branch_remote != 'upstream/master'
        end

        clone_db if File.exist?("../#{@branch}/config/database.yml")
        tmux
      end
    end

    private

    def clone_db
      h = YAML.load_file('config/database.yml')
      db_name = h['development']['database']
      db_port = h['development']['port']
      if TTY::Prompt.new.yes?("Clone database [#{db_name}]?")
        TTY::Command.new.run "createdb -h localhost -p #{db_port} -T #{db_name} #{@branch}_development"
        Dir.chdir("../#{@branch}") do
          h['development']['database'] = "#{@branch}_development"
          File.write('config/database.yml', h.to_yaml)
        end
      end
    end

    # when you are branching from different remote or remote branch
    # then creates .exrc file to make vim work properly with git
    def create_exrc
      File.open('.exrc', 'w') do |file|
        exrc_content = <<-EXRC
let g:pull_remote = '#{branch_remote.split('/')[0]}'
let g:pull_remote_branch = '#{branch_remote.split('/')[1]}'
        EXRC
        file.write(exrc_content)
      end
    end

    def branch_remote
      ARGV[2] || 'upstream/master'
    end

    def master_repo
      "#{Dir.pwd}/master"
    end

    def tmux
      tmux_session_name = @branch.tr('.', '-')
      TTY::Command.new.run "tmux new-session -t #{tmux_session_name} -d", chdir: "../#{@branch}"
      TTY::Command.new.run "tmux new-window -n vim", chdir: "../#{@branch}"
      TTY::Command.new.run 'tmux send-keys "vim" C-m'
      Kernel.system "tmux attach-session -t #{tmux_session_name}"
    end

    def copy_files
      #we are in master now
      if File.exist?('../.copy_files')
        file = File.open('../.copy_files').read
        file.each_line do |line|
          FileUtils.cp_r line.strip, "../#{@branch}/#{line.strip}"
        end
      end
    end
  end
end
