exports.getTimestampRange = (day) => {
  const dayStart = new Date(`${day}T00:00:00Z`).getTime();
  const dayEnd = new Date(`${day}T23:59:59Z`).getTime();
  return {dayStart, dayEnd};
};
