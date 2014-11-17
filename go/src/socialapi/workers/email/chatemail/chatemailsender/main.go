package main

import (
	"fmt"
	"koding/db/mongodb/modelhelper"
	"socialapi/workers/common/runner"
	"socialapi/workers/email/chatemail/chatemailsender/sender"
	"socialapi/workers/email/emailmodels"
	"socialapi/workers/helper"
)

const Name = "ChatEmailSender"

func main() {
	r := runner.New(Name)
	if err := r.Init(); err != nil {
		fmt.Println(err)
		return
	}

	modelhelper.Initialize(r.Conf.Mongo)

	redisConn := helper.MustInitRedisConn(r.Conf)
	defer redisConn.Close()

	es := emailmodels.NewEmailSettings(r.Conf)

	handler, err := sender.New(
		redisConn, r.Log, es,
	)
	if err != nil {
		r.Log.Error("Could not create chat email sender: %s", err)
	}

	r.ShutdownHandler = handler.Shutdown

	r.Listen()
	r.Wait()
}
