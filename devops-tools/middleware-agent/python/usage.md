```sh
pip install middleware-apm
```

```py
# add to top of main
import logging 
 
from middleware import MwTracker
tracker=MwTracker()
```

```sh
# docker
MW_AGENT_SERVICE=<DOCKER_BRIDGE_GATEWAY_ADDRESS>

# k8s
kubectl get service --all-namespaces | grep mw-service

MW_AGENT_SERVICE=mw-service.mw-agent-ns.svc.cluster.local
```

```yaml
# configure ini file
# 
[middleware.common]

# The name of your application as service-name, as it will appear in the UI to filter out your data.
service_name = {APM-SERVICE-NAME}

# This Token binds the Python Agent's data and profiling data to your account.
access_token = {YOUR-ACCESS-TOKEN}

# The service name, where Middleware Agent is running, in case of K8s.
mw_agent_service = mw-service.mw-agent-ns.svc.cluster.local

# Distributed traces for your application (false = disabled).
collect_traces = true

# Collection of metrics for your application (false = disabled).
collect_metrics = true

# Collection of logs for your application (false = disabled).
collect_logs = true

# Collection of profiling data for your application (false = disabled).
collect_profiling = true

```

```sh
MIDDLEWARE_CONFIG_FILE=./middleware.ini middleware-apm run python app.py
```