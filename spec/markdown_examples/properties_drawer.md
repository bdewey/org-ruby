# The mount point of the fullest disk

## query all mounted disks
```
  df \
```

## strip the header row
```
  |sed '1d' \
```

## sort by the percent full
```
  |awk '{print $5 " " $6}'|sort -n |tail -1 \
```

## extract the mount point
```
  |awk '{print $2}'
```

# Properties drawer example

These properties are metadata so they should not be visible.
