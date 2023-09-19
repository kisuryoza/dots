use std::ffi::CString;
use std::process::exit;

pub enum Fork {
    Parent(libc::pid_t),
    Child,
}

pub fn daemonize() {
    match fork() {
        Fork::Parent(_child_pid) => exit(0),
        Fork::Child => {
            // create new session
            if unsafe { libc::setsid() } < 0 {
                panic!("libc::setsid failed")
            }

            // close descriptors
            if unsafe { libc::close(0) + libc::close(1) + libc::close(2) } < 0 {
                panic!("libc::close(n) failed")
            }

            // change directory
            let root = CString::new("/").expect("CString::new failed");
            if unsafe { libc::chdir(root.as_ptr()) } < 0 {
                panic!("libc::chdir failed")
            }
        }
    }
}

fn fork() -> Fork {
    match unsafe { libc::fork() } {
        -1 => panic!("libc::fork failed"),
        0 => Fork::Child,
        child_pid => Fork::Parent(child_pid),
    }
}
