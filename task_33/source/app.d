import std.stdio;
import std.algorithm;
import std.range;

struct Task
{
	int deadline;
	int penalty;
}

struct ScheduleResult
{
	Task[] schedule;
	int totalPenalty;
}

// Assumes that tasks are sorted by penalty
ScheduleResult quiteOptimal(Task[] tasks)
{
	auto scheduleSize = tasks.map!(t => t.deadline).maxElement;
	auto parent = iota(scheduleSize).array;
	auto sizes = new int[scheduleSize];
	sizes[] = 1;
	auto low = iota(scheduleSize).array;

	int find(int i)
	{
		if (parent[i] == i)
		{
			return i;
		}
		parent[i] = find(parent[i]);
		return parent[i];
	}

	void unite(int i, int j)
	{
		i = find(i);
		j = find(j);

		if (i != j)
		{
			if (sizes[i] < sizes[j])
			{
				swap(i, j);
			}
			parent[j] = i;
			sizes[i] += sizes[j];
			low[i] = min(low[i], low[j]);
		}
	}

	auto finalSchedule = new Task[scheduleSize];
	auto totalPenalty = 0;

	foreach (task; tasks)
	{
		int availableDay = low[task.deadline - 1];

		if (availableDay == -1)
		{
			totalPenalty += task.penalty;
		}
		else
		{
			finalSchedule[availableDay] = task;
			
			if (availableDay > 0)
			{
				unite(availableDay, availableDay - 1);
			}
			else
			{
				low[find(0)] = -1;
			}
		}
	}
	return ScheduleResult(finalSchedule, totalPenalty);
}

ScheduleResult naive(Task[] tasks)
{
	auto maxDeadline = tasks.map!(t => t.deadline).maxElement;
	auto finalSchedule = new Task[maxDeadline];
	auto totalPenalty = 0;
	foreach (task; tasks)
	{
		auto placed = false;
		for (auto day = 0; day < task.deadline && day < maxDeadline; ++day)
		{
			if (finalSchedule[day].penalty == 0)
			{
				finalSchedule[day] = task;
				placed = true;
				break;
			}
		}

		if (!placed)
		{
			totalPenalty += task.penalty;
		}
	}

	return ScheduleResult(finalSchedule, totalPenalty);
}

// basic
unittest
{
	auto tasks = [
		Task(1, 3),
		Task(2, 2),
		Task(3, 1)
	];

	tasks.sort!((a, b) => a.penalty > b.penalty);
	auto result = quiteOptimal(tasks);

	assert(result.totalPenalty == 0);
	assert(result.schedule[0] == Task(1, 3));
	assert(result.schedule[1] == Task(2, 2));
	assert(result.schedule[2] == Task(3, 1));
}

// naive's nonoptimality and optimal's nonnaivete
unittest
{
	auto tasks = [
		Task(2, 20),
		Task(1, 11),
		Task(2, 10)
	];
	tasks.sort!((a, b) => a.penalty > b.penalty);

	auto result = naive(tasks);

	assert(result.totalPenalty == 11);
	assert(result.schedule[0] == Task(2, 20));
	assert(result.schedule[1] == Task(2, 10));

	auto optimalRes = quiteOptimal(tasks);

	assert(optimalRes.totalPenalty == 10);
	assert(optimalRes.schedule[0] == Task(1, 11));
	assert(optimalRes.schedule[1] == Task(2, 20));
}

void main()
{
	writeln("0xbebebe stub");
}
