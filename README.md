# fluent-plugin-tag-normaliser

Tag-normaliser is a [fluentd](https://docs.fluentd.org/) plugin to help re-tag logs with Kubernetes metadata coming from `fluent-bit` [kubernetes filter](https://github.com/fluent/fluent-bit-docs/blob/master/filter/kubernetes.md). 

## Installation

### RubyGems

```
$ gem install fluent-plugin-tag-normaliser
```

### Bundler

Add following line to your Gemfile:

```ruby
gem "fluent-plugin-tag-normaliser"
```

And then execute:

```
$ bundle
```

## Configuration

You only need to specify the `format` option.

```
<match example.tag**>
  @type tag_normaliser
  format cluster1.${namespace_name}.${pod_name}.${labels.app}
</match>
```

| Parameter | Description | Default |
|-----------|-------------|---------|
| key_prefix | Prefix used to access record attributes | kubernetes |
| format | Format to rewrite tag to. You can access record with `${record_name}` expression. Nested attributes available via `.` separator: `${labels.app}` | "" |
| unknown | Fallback value for missing record attribute | "unknown" |
| sticky_tags | Sticky tags will match only one record from an event stream. The same tag will be treated the same way | true |

### Available fluent-bit provided kubernetes attributes

| Parameter | Description | Example |
|-----------|-------------|---------|
| pod_name | Pod name | understood-butterfly-nginx-logging-demo-7dcdcfdcd7-h7p9n |
| container_name | Container name inside the Pod | nginx-logging-demo |
| namespace_name | Namespace name | default |
| pod_id | Kubernetes UUID for Pod | 1f50d309-45a6-11e9-b795-025000000001  |
| labels | Kubernetes Pod labels. This is a nested map. You can access nested attributes via `.`  | {"app":"nginx-logging-demo", "pod-template-hash":"7dcdcfdcd7" }  |
| host | Node hostname the Pod runs on | docker-desktop |
| docker_id | Docker UUID of the container | 3a38148aa37aa3... |


### Example

#### Configuration

```
<match example.tag**>
  @type tag_normaliser
  format cluster1.${namespace_name}.${pod_name}.${labels.app}
</match>
```

#### Input

```
tag = "kubernetes.var.log.containers.nginx-s6fvr_default_nginx-889831b33146bb9ec28a5700442b53c6cdf4c445fb5b71c0c48cfa27aaa00212.log"
```

```json
{  
   "log":"10.1.0.1 - - [13/Mar/2019:15:42:31 +0000] \"GET / HTTP/1.1\" 200 612 \"-\" \"kube-probe/1.13\" \"-\"\n",
   "kubernetes":{
      "pod_name":"understood-butterfly-nginx-logging-demo-7dcdcfdcd7-h7p9n",
      "namespace_name":"default",
      "pod_id":"1f50d309-45a6-11e9-b795-025000000001",
      "labels":{  
         "app":"nginx-logging-demo",
         "pod-template-hash":"7dcdcfdcd7",
         "release":"understood-butterfly"
      },
      "host":"docker-desktop",
      "container_name":"nginx-logging-demo",
      "docker_id":"3a38148aa37aa30e6e2df96af95cbda7a47b0428689bb4152413f4be25532fda"
   }
}
```

#### Output

```
tag = "cluster1.default.understood-butterfly-nginx-logging-demo-7dcdcfdcd7-h7p9n.nginx-logging-demo",
```


> You can use the plugin without Kubernetes labels just set `key_prefix` to empty string.

## Copyright

* Copyright(c) 2019- Banzai Cloud
* License
  * Apache License, Version 2.0
