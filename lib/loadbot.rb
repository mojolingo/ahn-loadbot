methods_for :dialplan do
  def bot_exec(plan)
    LoadBot.new(self, plan).run
  end
end

methods_for :rpc do
  def bot_call(plan_name)
    ahn_log.loadbot.debug COMPONENTS.loadbot.inspect
    config = COMPONENTS.loadbot['config']
    plan = COMPONENTS.loadbot['plans'][plan_name]
    
    raise ArgumentError, "No plan '#{plan_name}' exists in the loadbot config file" if plan.nil?
    # TODO: Add a check to ensure the number exists in the plan.

    manager = Adhearsion::VoIP::Asterisk.manager_interface
    manager.call_and_exec "#{config['prefix']}/#{plan['number']}", "agi", :args => "agi://#{config['agi_server']}/loadbot", :variables => {:plan => plan_name}
  end
end

class LoadBot
  def initialize(call, plan_name)
    ahn_log.loadbot.debug "Initializing LoadBot with plan: #{plan_name}"
    @call = call
    # TODO: Add a check to ensure plan exists and there is an answer array.
    @plan = COMPONENTS.loadbot['plans'][plan_name]
    @plan['name'] = plan_name
  end

  def run
    ahn_log.loadbot.info "Running LoadBot plan '#{@plan['name']}"

    # As it usually takes a second for an initial recording to kick in,
    # we wait a couple seconds before starting our test plan.
    sleep(2.seconds)

    # For each answer sequence we go through and submit requests
    # properly.
    @plan['answers'].each do |a|
      @call.execute 'WaitForSilence'
      ahn_log.loadbot.debug "Submitting answer: #{a}"
      @call.execute 'SendDTMF', a
      sleep(2.seconds)
    end

    @call.execute 'WaitForSilence'

  end
end
