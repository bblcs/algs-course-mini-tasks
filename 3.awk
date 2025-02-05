#!/usr/bin/awk -f

BEGIN {
  good = ARGV[1]
  bad = ARGV[2]
  test_command = ARGV[3]

  bisect(good, bad, test_command)
}

function bisect(good, bad, test_command) {
  mid = get_midpoint(good, bad)

  if (mid == "") {
    print "finished. bad: " bad
    exit
  }

  print "testing " mid
  stash_command = "git stash push -u -m 'Bisect save' 2> /dev/null"
  system(stash_command)

  checkout_command = "git checkout -q " mid " > /dev/null 2>&1"
  system(checkout_command)

  result = system(test_command)

  unstash_command = "git stash pop 2> /dev/null"
  system(unstash_command)

  if (result == 0) {
    print mid " is good"
    bisect(mid, bad, test_command)
  } else {
    print mid " is bad"
    bisect(good, mid, test_command)
  }
}

function get_midpoint(good, bad) {
  command = "git rev-list --count " good ".." bad " 2> /dev/null"
  command | getline commit_count
  close(command)

  if (commit_count == 0) {
    return ""
  }

  mid_position = int(commit_count / 2)

  command = "git rev-list " good ".." bad " | tail -n +" (mid_position + 1) " | head -n 1 2> /dev/null"
  command | getline midpoint
  close(command)

  return midpoint
}
