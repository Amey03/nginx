#!/bin/sh

if [ -f /sys/fs/cgroup/cpu/cpu.cfs_quota_us ]; then
  # cgroup v1
  export CPU_QUOTA=`cat /sys/fs/cgroup/cpu/cpu.cfs_quota_us`
  export CPU_PERIOD=`cat /sys/fs/cgroup/cpu/cpu.cfs_period_us`
  # Bash is integer math, this is a ceil function: 2 / 3 = 0
  export CPU_EFFECTIVE_CORES=$(( ( ( CPU_QUOTA - 1 ) / CPU_PERIOD ) + 1 ))

elif [ -f /sys/fs/cgroup/cpuset.cpus.effective ]; then
  # cgroup v2
  while IFS=',' read range
  do
    IFS='-' read start end < <(echo $range)
    [ -z "$start" ] && continue
    [ -z "$end" ] && end=$start

    TOTAL=$(( $TOTAL + ($end - $start) + 1 ))
  done < /sys/fs/cgroup/cpuset.cpus.effective

  export CPU_EFFECTIVE_CORES=$TOTAL
else
  export CPU_EFFECTIVE_CORES=1
fi

# Run confd to generate Nginx configuration
confd -onetime -backend env