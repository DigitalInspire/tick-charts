# `InfluxData Tick-Stack`
This is a collection of [Helm](https://github.com/kubernetes/helm) [Charts](https://github.com/kubernetes/charts) for the [InfluxData](https://influxdata.com/time-series-platform) TICK stack modified by Digital Inspire with special configuration settings.

> Note: This README will eventually point to other README's included in the according Helm Chart for further instructions specific to a component of the InfluxData Tick-Stack.

## Installation
To install all components with the correct settings, the following order should be considered where each individual `README` of the specified chart should be consulted!

1. [nginx-ingress](/nginx-ingress/README.md)
2. [influxdb](/influxdb/README.md)
3. [telegraf](/telegraf/README.md)
4. [kapacitor](/kapacitor/README.md)
5. [chronograf](/chronograf/README.md) (PARTIALLY READY / INGRESS REWRITE NOT WORKING WITH STATIC FILES)


## Deploy the whole stack!
**Although this is not recommended as there are further specific settings that need to be set for each individual chart to meet the desired output**, it is possible to deploy the whole stack by following the instructions below:

- Have your `kubectl` tool configured for the cluster where you would like to deploy the stack.
- Have `helm` and `tiller` installed and configured (also on your cluster)
- Install the charts:
```bash
$ cd tick-charts
$ helm install --name nginx-ingress --namespace kube-system --set controller.hostNetwork=true,controller.kind=DaemonSet nginx-ingress/
$ helm install --name influxdb --namespace tick-stack ./influxdb/
$ helm install --name telegraf --namespace tick-stack ./telegraf/
$ helm install --name kapacitor --namespace tick-stack ./kapacitor/
$ helm install --name chronograf --namespace tick-stack ./chronograf/
```
