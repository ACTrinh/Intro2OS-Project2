/*
Ho Thuy Tram
Trinh Thi Thu Hien
*/
#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int main(int argc, char *argv[]) {
    int p1[2]; // pipe: parent writes, child reads
    int p2[2]; // pipe: child writes, parent reads
    char recv_buf[5]; // buffer for received messages
    int status;

    pipe(p1); // create pipe for parent -> child
    pipe(p2); // create pipe for child -> parent

    if(fork() == 0) {
        // --- child process ---
        close(p1[1]); // close unused write end of p1
        read(p1[0], recv_buf, 4);  // read "ping"
        recv_buf[4] = '\0';
        close(p1[0]);

        printf("%d: received %s\n", getpid(), recv_buf);

        close(p2[0]); // close unused read end of p2
        write(p2[1], "pong", 4); // send response
        close(p2[1]);

        exit(0);
    }
    else {
        // --- parent process ---
        close(p1[0]); // close unused read end of p1
        write(p1[1], "ping", 4); // send message
        close(p1[1]);

        close(p2[1]); // close unused write end of p2
        read(p2[0], recv_buf, 4); // read response
        recv_buf[4] = '\0';
        close(p2[0]);

        printf("%d: received %s\n", getpid(), recv_buf);

        wait(&status);
        exit(0);
    }
}