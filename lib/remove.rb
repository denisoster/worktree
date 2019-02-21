require 'fileutils'
require 'logger'

module WorkTree
  class Remove
    def initialize(branch)
      @branch = branch
    end

    def do!
      if dir_exists?
        if TTY::Prompt.new.yes?("Do you want to remove #{Dir.pwd}/#{@branch}?")
          FileUtils.rm_r "#{Dir.pwd}/#{@branch}"
        end
      end

      git = Git.open("#{Dir.pwd}/master", log: Logger.new(STDOUT))

      Dir.chdir('master') do
        TTY::Command.new.run 'git worktree prune'
        #clear local cache
        git.fetch('origin', prune: true)
        # if remote branch exists then remove it also
        if Git.ls_remote(git.dir)['remotes'].keys.include?("origin/#{@branch}")
          if TTY::Prompt.new.yes?("Do you want to remove remote branch origin/#{@branch}?")
            git.push('origin', @branch, delete: true)
          end
        else
          puts "No remote branch origin/#{@branch} detected!"
        end
        # remove local branch
        git.branch(@branch).delete
      end
    end

    def dir_exists?
      Dir.exist?("#{Dir.pwd}/#{@branch}")
    end
  end
end
