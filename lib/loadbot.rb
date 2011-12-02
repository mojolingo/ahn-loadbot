methods_for :dialplan do
  def bot_exec(plan)
    LoadBot.new(self, plan).run
  end
end

methods_for :rpc do
  def bot_call(plan_name)
    ahn_log.loadbot.debug COMPONENTS.loadbot.inspect
    config = COMPONENTS.loadbot['config']
    plan = LoadBot.load_plan(plan_name)

    ahn_log.loadboat.debug "Calling #{config['prefix']}/#{plan['number']} with plan name #{plan_name}"
    
    manager = Adhearsion::VoIP::Asterisk.manager_interface
    manager.call_and_exec "#{config['prefix']}/#{plan['number']}", "agi", :args => "agi://#{config['agi_server']}/loadbot", :variables => {:plan => plan_name}, :caller_id => plan['caller_id']
end

class LoadBot
  def initialize(call, plan_name)
    ahn_log.loadbot.debug "Initializing LoadBot with plan: #{plan_name}"
    @call = call
    @plan = LoadBot.load_plan(plan_name)
  end

  def run
    ahn_log.loadbot.info "Running LoadBot plan '#{@plan['name']}"

    # TODO: put the average wait in the config file, remember, the
    # a per answer wait time will be added to wait if specified.
    wait = 2 # seconds

    # As it usually takes a second for an initial recording to kick in,
    # we wait before starting our test plan.
    sleep(wait.seconds)

    # For each answer sequence we go through and submit requests
    # properly.
    @plan['answers'].each do |a|
      @call.execute 'WaitForSilence'
      answer,delay = a.to_s.split(',')
      delay = delay.nil? ? 0 : delay.to_i
      ahn_log.loadbot.debug "Answer: #{answer} : Delay: #{delay} second(s)"

      case answer
      when "sleep"
        ahn_log.loadbot.debug "Sleeping..."
      when "hangup"
        ahn_log.loadbot.debug "Hanging Up."
        @call.hangup
      when /^play /
        file = answer.split(' ')[1]
        raise ArgumentError, "Test plan answer specifies play but with no sound file." if file.nil?
        ahn_log.loadbot.debug "Playing File: #{file}"
        @call.play! file
      else
        @call.dtmf answer
      end
      
      sleep wait + delay
    end

    @call.execute 'WaitForSilence'

  end

  def self.load_plan(plan_name)
    plan = COMPONENTS.loadbot['plans'][plan_name]

    raise ArgumentError, "No plan '#{plan_name} exists in the loadbot config file" if plan.nil?

    plan['name'] = plan_name

    # TODO: do some more sanity checks in here:
    # Does the plan have a number?
    # Does it have some answers? etc.

   plan

  end
end
