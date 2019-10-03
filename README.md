# K6 Grafana Dashboard
[![Build Status](https://travis-ci.org/electrocucaracha/k6board.png)](https://travis-ci.org/electrocucaracha/k6board)

## Summary

[K6][1] is a tool that allows to test performance of websites. The
output of this tool can be stored in a [InfluxDB][2] instance and
display this data through a [Grafana][3] dashboard.

This project pretends to increase the scope of its [documentation][4]
covering the installation and integration of the Database and
Dashboard using [Helm][5] charts.

![Dashboard](img/dashboard.png)

## Virtual Machines

This project uses [Vagrant tool][6] for provisioning Virtual Machines
automatically. It's highly recommended to use the  *setup.sh* script
of the [bootstrap-vagrant project][7] for installing Vagrant
dependencies and plugins required for its project. The script
supports two Virtualization providers (Libvirt and VirtualBox).

    $ curl -fsSL https://raw.githubusercontent.com/electrocucaracha/bootstrap-vagrant/master/setup.sh | PROVIDER=libvirt bash

Once Vagrant is installed, it's possible to provision a cluster using
the following instructions:

    $ vagrant up

This process will take some time to provision a Kubernetes Cluster and
install Helm services on it. This provisioning process is done through
the [KRD project][8]. Lastly, the `kubectl` command will create the
following resources defined in the [k6.yml](k6.yml) file:

| Name         | Kind       | Description                              |
|--------------|------------|------------------------------------------|
| envoy-config | ConfigMap  | [Envoy's configuration values][9]        |
| nginx        | Service    | An access point for the NGINX deployment |
| nginx        | Deployment | Deployment to be measured by k6 tools    |
| k6-config    | ConfigMap  | [k6's configuration values][1]           |
| k6-cron      | CronJob    | Defines a recurring job to execute k6    |

Given the Grafana's port is forwarded to the host machine it's
possible to access the dashboard using the following URL:

    http://localhost:30086/d/zEQRuwCik/k6-results

> Note: The Grafana's username is `admin` and its password is `secret`

## License

Apache-2.0

[1]: https://k6.io/
[2]: https://www.influxdata.com/
[3]: https://grafana.com/
[4]: https://docs.k6.io/docs/influxdb-grafana
[5]: https://helm.sh/
[6]: https://www.vagrantup.com/
[7]: https://github.com/electrocucaracha/bootstrap-vagrant
[8]: https://github.com/electrocucaracha/krd
[9]: https://www.envoyproxy.io/docs/envoy/latest/start/start#simple-configuration
