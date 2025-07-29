public class ScheduleLeadAssignment implements Schedulable{
	 public void execute(SchedulableContext sc) {

        SobjectLoadAssignment.ExecuteLoadAssignment(10); //RoundRobin
        scheduleNextRun();
    }


    public static void scheduleNextRun() {
        Datetime nextRunTime = System.now().addMinutes(1);

        String cronExp = nextRunTime.format('s m H d M \'?\' yyyy');

        System.schedule('QABatches:' + nextRunTime.getTime(), cronExp, new ScheduleLeadAssignment());
    }

    public static void scheduleJob() {
        scheduleNextRun();
    }


}