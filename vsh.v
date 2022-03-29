/*-
 * SPDX-License-Identifier: BSD-2-Clause
 * Copyright (c) 2022 Cameron Katri.  All rights reserved.
 */

module main

import os {
	chdir,
	expand_tilde_to_home,
	home_dir,
	input,
}

fn main() {
	ret := vsh_startloop()
	exit(ret)
}

pub fn vsh_startloop() int {
	for {
		cmd := input('> ')
		if cmd == '<EOF>' {
			exit(0)
		}
		args := vsh_parseargs(cmd)
		vsh_exec(args)
	}
	return 0
}

fn vsh_parseargs(cmd string) []string {
	return cmd.split_any(' \t\r\n\a')
}

fn vsh_exec(args []string) {
	match args[0] {
		'exit' {
			if args.len > 1 {
				exit(args[1].int())
			} else {
				exit(0)
			}
		}
		'cd' {
			mut path := home_dir()
			if args.len > 1 {
				path = expand_tilde_to_home(args[1])
			}
			chdir(path) or {
				eprintln(err)
				return
			}
		}
		'help' {
			println('Vsh')
			println('Builtins:')
			println('  cd\n  exit\n  help\n')
			println('https://github.com/CRKatri/vsh')
		}
		else {
			vsh_launch(args)
		}
	}
}

fn vsh_launch(args []string) {
	mut cmd := ''
	if args[0][0] == byte(`/`) {
		cmd = args[0]
	} else {
		cmd = os.find_abs_path_of_executable(args[0]) or { args[0] }
	}
	mut p := os.new_process(cmd)
	p.set_args(args[1..])
	p.run()
	p.wait()
}
