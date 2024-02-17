function deploy-aware
       for pod in consolidation grpc rails sidekiq shoryuken 
              set POD $argv[1]-$pod
              echo "Deploying pod $POD"
              impostor eks ship $POD (git branch --show-current)
       end
end
