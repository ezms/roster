import { builder } from './builder';

import './types/account';
import './types/school';
import './types/user';
import './types/student';
import './types/class';
import './types/attendance-session';
import './types/attendance-record';
import './types/attendance-report';

export const schema = builder.toSchema();
